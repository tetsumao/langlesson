module ApplicationHelper
  def current_user_path
    if current_user.teacher?
      teacher_path(current_user)
    elsif current_user.student?
      user_path(current_user)
    else
      nil
    end
  end
end
