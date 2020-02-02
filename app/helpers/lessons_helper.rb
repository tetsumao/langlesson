module LessonsHelper
  def period_select_collection(periods)
    periods.map{ |period| [period.period_name, period.id] }
  end
end
