class AddStripeCusidToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :stripe_cusid, :string
  end
end
