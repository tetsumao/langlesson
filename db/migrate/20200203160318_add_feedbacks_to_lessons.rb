class AddFeedbacksToLessons < ActiveRecord::Migration[6.0]
  def change
    add_column :lessons, :feedback, :text
    add_column :lessons, :report, :text
  end
end
