Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
  secret_key: ENV['STRIPE_SECRET_KEY']
}
Stripe.api_key = Rails.configuration.stripe[:secret_key]

# 定期プラン
STRIPE_PLANS = [:none, :lite, :standard, :heavy]
STRIPE_PLAN_ID = {
  lite: ENV['STRIPE_PLAN_LITE'],
  standard: ENV['STRIPE_PLAN_STANDARD'],
  heavy: ENV['STRIPE_PLAN_HEAVY']
}
