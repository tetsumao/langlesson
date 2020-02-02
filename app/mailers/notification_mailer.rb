class NotificationMailer < ApplicationMailer
  def send_reservation_to_student(lesson)
    @lesson = lesson
    mail subject: "レッスンを予約しました(#{@lesson.summary})", to: @lesson.ticket.user.email do |format|
      format.text
    end
  end

  def send_reservation_to_teacher(lesson)
    @lesson = lesson
    mail subject: "レッスンが予約されました(#{@lesson.summary})", to: @lesson.user.email do |format|
      format.text
    end
  end
end
