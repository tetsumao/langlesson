class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  authorize_resource

  def index
    @tickets = @user.tickets.order(id: :desc).page(params[:page]).per(10)
  end

  def new
    @ticket = @user.tickets.build
  end

  def create
    @ticket = @user.tickets.build(ticket_params)
    @ticket.stripe_token = params[:stripeToken]
    respond_to do |format|
      if @ticket.payment
        format.html { redirect_to user_tickets_path(@user), notice: "#{Ticket.model_name.human}を作成しました。" }
      else
        format.html { render :new }
      end
    end
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    def ticket_params
      params.require(:ticket).permit(:user_id, :number_owned)
    end
end
