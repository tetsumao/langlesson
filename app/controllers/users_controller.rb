class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show]

  def show
    if current_user.student? && current_user != @user
      redirect_to root_path, notice: "他のユーザの#{User.model_name.human}情報は閲覧できません。"
    end
    @lessons = @user.reserved_lessons.fineshed.order_desc.page(params[:page]).per(10)
  end

  private
    def set_user
      @user = User.students.find(params[:id])
    end
end
