class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, except: [:search, :reserved]
  before_action :set_lesson, only: [:show, :edit, :update, :destroy, :reserve]
  before_action :confirm_reserved, only: [:edit, :update, :destroy]
  authorize_resource

  def index
    @lessons = @user.lessons.not_fineshed.not_reservables.order_asc.page(params[:page]).per(20)
    @reservable_lessons = @user.lessons.reservables.order_asc.page(params[:page]).per(20)
  end

  def history
    @lessons = @user.lessons.fineshed.not_reservables.order_desc.page(params[:page]).per(20)
  end

  def show
  end

  def new
    @lesson = @user.lessons.build
  end

  def edit
  end

  def create
    @lesson = @user.lessons.build(lesson_params)

    respond_to do |format|
      if @lesson.save
        format.html { redirect_to teacher_lesson_path(@user, @lesson), notice: "#{Lesson.model_name.human}を作成しました。" }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @lesson.update(lesson_params)
        format.html { redirect_to teacher_lesson_path(@user, @lesson), notice: "#{Lesson.model_name.human}を更新しました。" }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @lesson.destroy
    respond_to do |format|
      format.html { redirect_to teacher_lessons_url(@user), notice: "#{Lesson.model_name.human}を削除しました。" }
    end
  end

  # 以下、生徒向け
  def search
    @search_params = lesson_serach_params
    @lessons = Lesson.not_fineshed.reservables
      .teacher_name_like(@search_params[:teacher_name])
      .date_from(@search_params[:date_from])
      .date_to(@search_params[:date_to])
      .time_from(@search_params[:time_from])
      .time_to(@search_params[:time_to])
      .category_id_is(@search_params[:category_id])
      .order_asc.page(params[:page]).per(20)
  end

  def reserve
    respond_to do |format|
      if @lesson.reserve(current_user)
        format.html { redirect_to root_path, notice: "#{Lesson.model_name.human}を予約しました。" }
      else
        format.html { render :show }
      end
    end
  end

  def reserved
    @lessons = current_user.reserved_lessons.not_fineshed.order_asc.page(params[:page]).per(20)
    @finished_lessons = current_user.reserved_lessons.fineshed.order_desc.page(params[:page]).per(20)
  end

  private
    def set_user
      @user = User.teachers.find(params[:teacher_id])
    end
    def set_lesson
      @lesson = @user.lessons.find(params[:id])
    end
    def confirm_reserved
      if @lesson.reserved?
        redirect_to teacher_lesson_path(@user, @lesson), notice: "予約済みの#{Lesson.model_name.human}は編集・削除できません。"
      end
    end

    def lesson_params
      params.require(:lesson).permit(:user_id, :date_at, :period_id, :category_id)
    end

    def lesson_serach_params
      params.fetch(:search, {}).permit(:teacher_name, :date_from, :date_to, :time_from, :time_to, :category_id)
    end
end
