module PeriodsHelper
  def period_select_collection(periods)
    periods.map{ |period| [period.period_name, period.id] }
  end

  def period_string_to_time(time)
    if time.is_a?(String)
      Time.strptime(time, '%H:%M')
    else
      time
    end
  end
end
