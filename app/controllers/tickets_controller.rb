class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_customer, only: [:new]
  authorize_resource

  def index
    @tickets = @user.tickets.order(id: :desc).page(params[:page]).per(10)
  end

  def new
    @ticket = @user.tickets.build
    if @customer.present?
      @card = @customer.sources.data[0] if @customer.sources.total_count > 0
      @plan = STRIPE_PLAN_ID.key(@customer.subscriptions.data[0].items.data[0].plan.id) if @customer.subscriptions.total_count > 0
    end
  end

  def create
    @ticket = @user.tickets.build(ticket_params)
    @ticket.stripe_token = params[:stripeToken]
    respond_to do |format|
      if @ticket.payment
        format.html { redirect_to tickets_path, notice: "#{Ticket.model_name.human}を購入しました。" }
      else
        format.html { render :new }
      end
    end
  end

  private
    def set_user
      @user = current_user
    end
    def set_customer
      @customer = Stripe::Customer.retrieve(@user.stripe_cusid) if @user.stripe_cusid.present?
    end

    def ticket_params
      params.require(:ticket).permit(:number_owned)
    end
end
