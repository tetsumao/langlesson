# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  def send_reservation_to_student
    lesson = Lesson.last
    NotificationMailer.send_reservation_to_student(lesson)
  end

  def send_reservation_to_teacher
    lesson = Lesson.first
    NotificationMailer.send_reservation_to_teacher(lesson)
  end
end
