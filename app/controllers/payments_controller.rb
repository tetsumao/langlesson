class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_customer
  authorize_resource class: false

  def card
    if @customer.present?
      @card = @customer.sources.data[0] if @customer.sources.total_count > 0
      @plan = STRIPE_PLAN_ID.key(@customer.subscriptions.data[0].items.data[0].plan.id) if @customer.subscriptions.total_count > 0
    end
  end

  def register_card
    attribtes = { email: @user.email, source: params[:stripeToken] }
    if @customer.nil?
      @customer = Stripe::Customer.create(attribtes)
      @user.update!(stripe_cusid: @customer.id)
    else
      @customer = Stripe::Customer.update(@customer.id, attribtes)
    end
    respond_to do |format|
      format.html { redirect_to payments_card_path, notice: "カード情報を登録しました。" }
    end
  end

  def delete_card
    if @customer.present?
      if @customer.subscriptions.total_count <= 0
        @customer.sources.data.each do |card|
          Stripe::Customer.delete_source(@customer.id, card.id)
        end
        message = "カード情報を削除しました。"
      else
        message = "定期購入中はカード情報を削除できません。"
      end
    else
      message = "カード情報がありません。"
    end
    respond_to do |format|
      format.html { redirect_to payments_card_path, notice: message }
    end
  end

  def subscription
    @plan = params['stripe_plan'].to_sym
    if STRIPE_PLANS.include?(@plan)
      if @customer.present? && @customer.sources.total_count > 0
        if @customer.subscriptions.total_count > 0
          subscription = @customer.subscriptions.data[0]
          if @plan == :none
            Stripe::Subscription.delete(subscription.id)
            message = '定期購入を休止しました。'
          else
            Stripe::SubscriptionItem.update(subscription.items.data[0].id, plan: STRIPE_PLAN_ID[@plan])
            message = '定期購入を変更しました。'
          end
        elsif @plan != :none
          Stripe::Subscription.create(customer: @customer.id, items: [{plan: STRIPE_PLAN_ID[@plan]}])
          message = '定期購入登録しました。'
        end
      else
        message = 'カード情報が登録されていません。'
      end
    else
      message = 'プラン選択が不正です'
    end
    respond_to do |format|
      format.html { redirect_to tickets_path, notice: message }
    end
  end

  def history
    if @customer.present?
      @invoices = Kaminari.paginate_array(Stripe::Invoice.list(customer: @customer.id).data).page(params[:page]).per(10)
    else
      @invoices = []
    end
  end

  private
    def set_user
      @user = current_user
    end
    def set_customer
      @customer = Stripe::Customer.retrieve(@user.stripe_cusid) if @user.stripe_cusid.present?
    end
end
