class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :number_owned, default: 1

      t.timestamps
    end
  end
end
