class TeachersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy, :proxy_sign_in]
  before_action :confirm_other_teacher?, only: [:edit, :update]
  authorize_resource class: false

  def index
    @users = User.teachers.order(id: :desc).page(params[:page]).per(20)
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    @user.authority = :teacher
    respond_to do |format|
      if @user.save
        format.html { redirect_to teacher_path(@user), notice: "#{User.human_attribute_name 'authority.teacher'}を作成しました。" }
      else
        format.html { render :new }
      end
    end
  end

  def update
    ups = user_params
    ups.delete(:password) if ups.has_key?(:password) && ups[:password].empty?
    respond_to do |format|
      if @user.update(ups)
        format.html { redirect_to teacher_path(@user), notice: "#{User.human_attribute_name 'authority.teacher'}を更新しました。" }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to teachers_url, notice: "#{User.human_attribute_name 'authority.teacher'}を削除しました。" }
    end
  end

  def proxy_sign_in
    sign_in(:user, @user)
    redirect_to root_url
  end

  private
    def set_user
      @user = User.teachers.find(params[:id])
    end
    def confirm_other_teacher?
      if current_user.teacher? && @user != current_user
        redirect_to teacher_path(@user), notice: "他の#{User.human_attribute_name 'authority.teacher'}は編集できません。"
      end
    end

    def user_params
      permits = [:user_name, :picture, :profile, user_categories_attributes: [:id, :category_id]]
      permits += [:email, :password] if current_user.admin?
      params.require(:user).permit(permits)
    end
end
