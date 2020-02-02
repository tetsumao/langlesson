class CreatePeriods < ActiveRecord::Migration[6.0]
  def change
    create_table :periods do |t|
      t.string :start_time
      t.string :end_time

      t.timestamps
    end
  end
end
