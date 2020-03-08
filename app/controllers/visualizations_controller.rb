class VisualizationsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource class: false

  def by_date
    @range_params = visualization_range_params
    @lessons = Lesson
      .date_from(@range_params[:date_from])
      .date_to(@range_params[:date_to])
      .time_from(@range_params[:time_from])
      .time_to(@range_params[:time_to])
      .reservation_rate_by_date_and_period.order(date_at: :asc).page(params[:page]).per(50)
    @periods = Period
      .time_from(@range_params[:time_from])
      .time_to(@range_params[:time_to])
      .order_asc
  end

  def by_teacher
    year_month_params = visualization_year_month_params
    @year_month = Date.new(year_month_params[:year].to_i, year_month_params[:month].to_i)
    @lessons = Lesson.date_start_and_next(@year_month, @year_month.next_year).reservation_rate_by_teacher_and_month.order(month_at: :asc)
    @teachers = User.teachers.order(id: :desc).page(params[:page]).per(20)
  end

  def by_teacher_detail
    week_params = visualization_week_params
    @date = Date.new(week_params[:year].to_i, week_params[:month].to_i, week_params[:day].to_i)
    @date -= @date.wday
    @lessons = Lesson.date_start_and_next(@date, @date + 7).reservation_rate_by_teacher_and_date.order(date_at: :asc)
    @teachers = User.teachers.order(id: :desc).page(params[:page]).per(20)
    date_beggining = @date.beginning_of_month
    @lessons_wday = Lesson.date_start_and_next(date_beggining, date_beggining.next_month).reservation_rate_by_teacher_and_wday.order(wday: :asc)
  end

  def by_category
    year_month_params = visualization_year_month_params
    @year_month = Date.new(year_month_params[:year].to_i, year_month_params[:month].to_i)
    @lessons = Lesson.date_start_and_next(@year_month, @year_month.next_year).reservation_rate_by_category_and_month.order(month_at: :asc)
    @categories = Category.all.order(id: :desc).page(params[:page]).per(20)
  end

  def by_category_detail
    week_params = visualization_week_params
    @date = Date.new(week_params[:year].to_i, week_params[:month].to_i, week_params[:day].to_i)
    @date -= @date.wday
    @lessons = Lesson.date_start_and_next(@date, @date + 7).reservation_rate_by_category_and_date.order(date_at: :asc)
    @categories = Category.all.order(id: :desc).page(params[:page]).per(20)
    date_beggining = @date.beginning_of_month
    @lessons_wday = Lesson.date_start_and_next(date_beggining, date_beggining.next_month).reservation_rate_by_category_and_wday.order(wday: :asc)
  end

  private
    def visualization_range_params
      default_date = Date.today - 7
      params.fetch(:range, {date_from: default_date.strftime('%F')}).permit(:date_from, :date_to, :time_from, :time_to)
    end
    def visualization_year_month_params
      default_date = Date.today << 6
      params.fetch(:year_month, {year: default_date.year, month: default_date.month}).permit(:year, :month)
    end
    def visualization_week_params
      default_date = Date.today
      params.fetch(:week, {year: default_date.year, month: default_date.month, day: default_date.day}).permit(:year, :month, :day)
    end
end
