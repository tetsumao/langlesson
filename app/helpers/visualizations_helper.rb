module VisualizationsHelper
  def visualization_td_rate_tag(lesson)
    if lesson.present?
      rate = 100.0 * lesson.number_reserved / lesson.number_lesson
      class_name = 'align-middle text-center'
      if rate <= 50.0
        class_name += ' rate-50'
      elsif rate <= 85.0
        class_name += ' rate-85'
      else
        class_name += ' rate-100'
      end
      tag.td "#{lesson.number_reserved} / #{lesson.number_lesson}", class: class_name
    else
      tag.td
    end
  end

  def date_to_s_with_wday(date)
    date.strftime("%Y/%m/%d(#{wday_to_s(date.wday)})")
  end
  def wday_to_s(wday)
    '日月火水木金土'[wday]
  end

  def date_to_year_month_params(date)
    {year_month: {year: date.year, month: date.month}}
  end
  def date_to_week_params(date)
    {week: {year: date.year, month: date.month, day: date.day}}
  end
end
