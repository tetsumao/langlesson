namespace :scheduler do
  desc 'Heroku schedulerから定期決済チケットを生成するタスク'
  task stripe_plan: :environment do
    # 1日分を確認
    invoices = Stripe::Invoice.list(created: {gte: Time.now.yesterday.to_i})
    invoices.data.each do |invoice|
      unless Ticket.where(stripe_invid: invoice.id).exists?
        user = User.find_by(stripe_cusid: invoice.customer)
        plan = STRIPE_PLAN_ID.key(invoice.lines.data[0].plan.id) if invoice.lines.total_count > 0
        if user.present? && plan.present?
          ticket_params = {due_at: (Date.today + 29), stripe_invid: invoice.id}
          if plan == :heavy
            ticket_params[:number_owned] = 10
          elsif plan == :standard
            ticket_params[:number_owned] = 7
          else
            ticket_params[:number_owned] = 5
          end
          ticket = user.tickets.build(ticket_params)
          ticket.save
        end
      end
    end
  end
end
