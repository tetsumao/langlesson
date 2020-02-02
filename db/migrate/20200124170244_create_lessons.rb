class CreateLessons < ActiveRecord::Migration[6.0]
  def change
    create_table :lessons do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date_at
      t.references :period, null: false, foreign_key: true
      t.references :category, null: true, foreign_key: true
      t.references :ticket, null: true, foreign_key: true
      t.string :zoom_url

      t.timestamps
    end
  end
end
