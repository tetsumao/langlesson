class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.admin?
      redirect_to teachers_path
    elsif current_user.teacher?
      redirect_to teacher_lessons_path(current_user)
    else
      redirect_to lessons_reserved_path
    end
  end
end
