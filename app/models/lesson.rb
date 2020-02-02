class Lesson < ApplicationRecord
  belongs_to :user
  belongs_to :period
  belongs_to :category
  belongs_to :ticket, optional: true

  validates_presence_of :date_at
  validates_presence_of :period_id
  validates_presence_of :category_id
  validate :validate_time_overlaps
  
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

  def reserve(student_user)
    if self.new_record?
      self.errors.add(:user, '登録されていないレッスンです。')
    elsif self.reserved?
      self.errors.add(:ticket, '既に予約済みです。')
    elsif self.finished?
      self.errors.add(:ticket, '既に終了済みです。')
    else
      self.ticket = student_user.usable_ticket
      if self.ticket.nil?
        self.errors.add(:ticket, '使用可能なチケットがありません')
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
end
