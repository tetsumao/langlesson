class Period < ApplicationRecord
  validate :validate_times

  def period_name
    self.start_time + '～の回'
  end

  def start_time_minutes
    Period.time_to_minutes(self.start_time)
  end

  def end_time_minutes
    Period.time_to_minutes(self.end_time)
  end

  def duration
    (self.end_time_minutes - self.start_time_minutes)
  end

  private
    def self.time_format_error?(time)
      !Time.strptime(time, '%H:%M') rescue true
    end

    def self.time_to_minutes(time)
      (time.slice(0, 2).to_i * 60 + time.slice(3, 2).to_i)
    end

    def validate_times
      if Period.time_format_error?(self.start_time)
        errors.add(:start_time, "開始時刻のフォーマットエラーです。")
      end
      if Period.time_format_error?(self.end_time)
        errors.add(:end_time, "終了時刻のフォーマットエラーです。")
      end
      if self.start_time >= self.end_time
        errors.add(:start_time, "＜終了時刻になるように設定してください。")
      end
    end
end
