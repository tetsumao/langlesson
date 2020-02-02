class CreateUserCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :user_categories do |t|
      t.references :user, foreign_key: true
      t.references :category, foreign_key: true

      t.timestamps

      t.index [:user_id, :category_id], unique: true
    end
  end
end
