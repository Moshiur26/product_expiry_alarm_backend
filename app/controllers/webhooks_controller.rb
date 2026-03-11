class WebhooksController < ApplicationController
  before_action :verify_webhook

  def orders_create
    OrdersCreateJob.perform_later(shop_domain, parsed_payload)
    head :ok
  end

  def app_uninstalled
    shop = Shop.find_by(shopify_domain: shop_domain)
    shop&.destroy
    head :ok
  end

  private

  def verify_webhook
    hmac = request.headers["X-Shopify-Hmac-Sha256"].to_s
    body = request.raw_post
    digest = Base64.strict_encode64(OpenSSL::HMAC.digest("sha256", ENV.fetch("SHOPIFY_API_SECRET"), body))

    unless ActiveSupport::SecurityUtils.secure_compare(digest, hmac)
      render json: { error: "Invalid webhook HMAC" }, status: :unauthorized
    end
  end

  def shop_domain
    request.headers["X-Shopify-Shop-Domain"].to_s
  end

  def parsed_payload
    JSON.parse(request.raw_post)
  end
end
