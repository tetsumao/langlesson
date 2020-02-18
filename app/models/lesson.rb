class Lesson < ApplicationRecord
  belongs_to :user
  belongs_to :period
  belongs_to :category
  belongs_to :ticket, optional: true

  validates_presence_of :date_at
  validates_presence_of :period_id
  validates_presence_of :category_id
  validate :validate_time_overlaps

  after_update :notify_feedback_changed

  # PostgresとSQLiteの書式の違い
  SQL_DATE_AT_TO_MONTH = Rails.env.production? ? "to_char(date_at, 'YYYY-MM-01')" : "strftime('%Y-%m-01', date_at)"
  SQL_DATE_AT_TO_WDAY = Rails.env.production? ? "(TO_NUMBER(to_char(date_at, 'D')) - 1)" : "(CAST(strftime('%w', date_at) AS INTEGER))"
  
  scope :reservables, -> { where(ticket_id: nil) }
  scope :not_reservables, -> { where.not(ticket_id: nil) }
  scope :fineshed, -> { joins(:period).where('date_at < :date OR (date_at = :date AND end_time < :time)', date: Date.today, time: Time.now.strftime('%H:%M')) }
  scope :not_fineshed, -> { joins(:period).where('date_at > :date OR (date_at = :date AND end_time >= :time)', date: Date.today, time: Time.now.strftime('%H:%M')) }

  scope :order_asc, -> { joins(:period).order('date_at ASC, start_time ASC') }
  scope :order_desc, -> { joins(:period).order('date_at DESC, start_time DESC') }

  scope :teacher_name_like, -> (name) { joins(:user).where('user_name LIKE ?', "%#{name}%") if name.present? }
  scope :date_from, -> (from) { where('date_at >= ?', from) if from.present? }
  scope :date_to, -> (to) { where('date_at <= ?', to) if to.present? }
  scope :time_from, -> (from) { joins(:period).where('start_time >= ?', from) if from.present? }
  scope :time_to, -> (to) { joins(:period).where('end_time <= ?', to) if to.present? }
  scope :category_id_is, -> (id) { where(category_id: id) if id.present? }

  scope :date_start_and_next, -> (date1, date2) { where(['date_at >= ? AND date_at < ?', date1, date2]) }
  scope :reservation_rate_by_date, -> (select_columns, group_columns) { select("#{select_columns}, COUNT(tickets.id) AS number_reserved, COUNT(lessons.id) AS number_lesson").left_joins(:ticket).group(group_columns) }
  scope :reservation_rate_by_date_and_period, -> { reservation_rate_by_date('date_at, period_id', 'date_at, period_id') }
  scope :reservation_rate_by_teacher_and_month, -> { reservation_rate_by_date("lessons.user_id, #{SQL_DATE_AT_TO_MONTH} AS date_at", "lessons.user_id, #{SQL_DATE_AT_TO_MONTH}") }
  scope :reservation_rate_by_teacher_and_date, -> { reservation_rate_by_date('lessons.user_id, date_at', 'lessons.user_id, date_at') }
  scope :reservation_rate_by_teacher_and_wday, -> { reservation_rate_by_date("lessons.user_id, #{SQL_DATE_AT_TO_WDAY} AS wday", 'lessons.user_id, wday') }
  scope :reservation_rate_by_category_and_month, -> { reservation_rate_by_date("category_id, #{SQL_DATE_AT_TO_MONTH} AS date_at", "category_id, #{SQL_DATE_AT_TO_MONTH}") }
  scope :reservation_rate_by_category_and_date, -> { reservation_rate_by_date('category_id, date_at', 'category_id, date_at') }
  scope :reservation_rate_by_category_and_wday, -> { reservation_rate_by_date("category_id, #{SQL_DATE_AT_TO_WDAY} AS wday", 'category_id, wday') }

  def reserve(student_user)
    if self.new_record?
      self.errors.add(:user, 'エラー。登録されていないレッスンです。')
    elsif self.reserved?
      self.errors.add(:ticket, 'エラー。既に予約済みです。')
    elsif self.finished?
      self.errors.add(:ticket, 'エラー。既に終了済みです。')
    else
      self.ticket = student_user.usable_ticket
      if self.ticket.nil?
        self.errors.add(:ticket, 'エラー。使用可能なチケットがありません。')
      else
        # Zoomミーティング作成
        zoom_client = Zoom.new
        meeting = zoom_client.meeting_create(user_id: $zoom_user_id, type: 2, timezone: 'Asia/Tokyo',
          start_time: "#{self.date_at.strftime('%Y-%m-%d')}T#{self.period.start_time}:00",
          duration: self.period.duration,
          topic: "#{self.user.user_name}(#{self.user.id})->#{self.ticket.user.user_name}(#{self.ticket.user.id}) - #{self.summary}")
        self.zoom_url = meeting['join_url']
        # 通知メール
        NotificationMailer.send_reservation_to_student(self).deliver_later
        NotificationMailer.send_reservation_to_teacher(self).deliver_later
        return self.save
      end
    end
    false
  end

  def reserved?
    self.ticket.present?
  end

  def finished?
    date = Date.today
    time = Time.now.strftime('%H:%M')
    (self.date_at < date || (self.date_at == date && self.period.end_time < time))
  end

  def time_overlaps
    Lesson.joins(:period).where(date_at: self.date_at).where.not(id: self.id)
      .where('periods.start_time < :end_time AND periods.end_time > :start_time', start_time: self.period.start_time, end_time: self.period.end_time)
  end

  def summary
    "#{self.date_at} #{self.period.period_name} #{self.category.category_name}"
  end

  private
    def validate_time_overlaps
      # 講師または生徒のレッスン時間枠の重複確認
      if self.time_overlaps.where(user_id: self.user_id).exists?
        errors.add(:date_at, "と時間枠の組み合わせは講師が重複するレッスンがあります。")
      end
      if self.reserved? && self.time_overlaps.joins(:ticket).where('tickets.user_id = ?', self.ticket.user_id).exists?
        errors.add(:date_at, "と時間枠の組み合わせは生徒が重複するレッスンがあります。")
      end
    end

    def notify_feedback_changed
      # フィードバック変更時にメール送信
      NotificationMailer.send_feedback_to_student(self).deliver_later if self.reserved? && self.saved_change_to_feedback?
    end
end
