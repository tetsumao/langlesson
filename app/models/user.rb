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
          temp_categoriy_ids.push(categoriy_id)
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
