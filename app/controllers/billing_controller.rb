class BillingController < ApplicationController
  before_action :require_shop!

  def create
    plan = params.fetch(:plan)
    price = params.fetch(:price)
    return_url = params[:return_url].presence || ENV.fetch("BILLING_RETURN_URL", "#{request.base_url}/billing/confirm")

    service = BillingService.new(current_shop)
    result = service.create_subscription(plan_name: plan, price: price, return_url: return_url)

    Subscription.create!(
      shop: current_shop,
      plan: plan,
      status: result[:charge]["status"],
      shopify_charge_id: result[:charge]["id"]
    )

    render json: { confirmation_url: result[:confirmation_url] }
  rescue KeyError
    render json: { error: "Missing plan or price" }, status: :bad_request
  rescue ShopifyApiService::ShopifyApiError => e
    render json: { error: e.message }, status: :bad_gateway
  end

  def confirm
    charge_id = params.fetch(:charge_id)
    service = BillingService.new(current_shop)
    charge = service.fetch_subscription(charge_id)

    subscription = Subscription.find_by(shopify_charge_id: charge_id)
    subscription&.update(status: charge["status"])

    render json: { status: charge["status"], plan: charge["name"] }
  rescue KeyError
    render json: { error: "Missing charge_id" }, status: :bad_request
  end
end
