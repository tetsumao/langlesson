module PaymentsHelper
  def stripe_plan_select_items
    h_item = {}
    STRIPE_PLANS.each do |plan|
      h_item[t("stripe_plan.#{plan}")] = plan
    end
    h_item
  end
end
