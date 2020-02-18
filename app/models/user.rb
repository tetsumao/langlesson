class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  enum authority: {student: 0, teacher: 1, admin: 99}

  validates_uniqueness_of :email
  validates_presence_of :email
  validates :profile, length: {maximum: 200}

  after_create :create_free_ticket

  has_many :lessons, dependent: :destroy
  has_many :user_categories, inverse_of: :user, dependent: :destroy
  has_many :categories, through: :user_categories, source: :category
  has_many :tickets, dependent: :destroy
  has_many :reserved_lessons, through: :tickets, source: :lessons

  accepts_nested_attributes_for :user_categories, reject_if: :reject_category_blank, allow_destroy: true
  attr_accessor :temp_categoriy_ids

  mount_uploader :picture, PictureUploader

  scope :students, -> { where(authority: :student) }
  scope :teachers, -> { where(authority: :teacher) }
  scope :admins,   -> { where(authority: :admin) }

  def usable_ticket
    usable_tickets_with_number_used.select('sub.*').order(created_at: 'ASC').first
  end

  def usable_ticket_count
    usable_tickets_with_number_used.sum('number_owned - number_used')
  end

  # レッスンの一括登録
  def save_lessons(lessons_params = [])
    success = true
    # パラメータ毎のレコード
    lessons_by_params = []
    lessons_params.each do |lps|
      lessons = []
      lesson_params = lps.dup
      # 日付範囲の日付配列を生成する
      date_ats = []
      date_from = lesson_params.delete(:date_from)
      date_to = lesson_params.delete(:date_to)
      if date_from.present?
        if date_to.present?
          date_from = date_from.to_date
          date_to = date_to.to_date
          date = date_from
          while date <= date_to
            date_ats << date
            date += 1
          end
        else
          date_ats << date_from
        end
      elsif date_to.present?
        date_ats << date_to
      else
        date_ats << lesson_params[:date_at] if lesson_params[:date_at].present?
      end
      # 時間枠の配列
      period_ids = lesson_params.delete(:period_ids) || []
      period_ids = [lesson_params[:period_id]] if period_ids.empty? && lesson_params[:period_id].present?
      # レッスンを生成
      date_ats.each do |date_at|
        period_ids.each do |period_id|
          lesson_params[:date_at] = date_at
          lesson_params[:period_id] = period_id
          lessons << self.lessons.build(lesson_params)
        end
      end
      lessons_by_params << lessons
      if lessons.empty?
        lps[:errors] = ['実施日または時間枠の指定が不正です。']
        success = false
      end
    end

    # 複数件数保存し、1件でもバリデーションエラーがあったらロールバック
    ActiveRecord::Base.transaction do
      lessons_by_params.each_with_index do |lessons, index|
        lesson_params = lessons_params[index]
        lessons.each do |lesson|
          unless lesson.save
            lesson_params[:errors] = [] unless lesson_params.has_key?(:errors)
            lesson_params[:errors] += lesson.errors.full_messages
            success = false
          end
        end
      end
      raise ActiveRecord::RecordInvalid unless success
      success
    end
    rescue
      success = false
    success
  end

  private
    def create_free_ticket
      # 無料チケット
      self.tickets.build(number_owned: :one).save if self.student?
    end

    def reject_category_blank(attributes)
      # カラと重複するカテゴリを外す
      self.temp_categoriy_ids = [] if self.temp_categoriy_ids.nil?

      if attributes[:category_id].present?
        categoriy_id = attributes[:category_id].to_i
        if temp_categoriy_ids.include?(categoriy_id)
          categoriy_id = nil
        else
          temp_categoriy_ids << categoriy_id
        end
      end
      if attributes[:id].present?
        attributes.merge!(_destroy: 1) if categoriy_id.nil?
        false
      else
        categoriy_id.nil?
      end
    end

    def usable_tickets_with_number_used
      # サブクエリで使用カウント(number_used)を集計
      subquery = self.tickets.left_joins(:lessons).group(:id).select('tickets.*, COUNT(lessons.id) AS number_used')
      Ticket.from("(#{subquery.to_sql}) AS sub").where('number_used < number_owned')
    end
end
