class AddDueAtAndStripeInvidToTickets < ActiveRecord::Migration[6.0]
  def change
    add_column :tickets, :due_at, :date
    add_column :tickets, :stripe_invid, :string
  end
end
