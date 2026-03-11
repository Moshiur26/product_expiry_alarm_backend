class OrdersCreateJob < ApplicationJob
  queue_as :default

  def perform(shop_domain, payload)
    shop = Shop.find_by(shopify_domain: shop_domain)
    return if shop.nil?

    Order.create!(
      shop: shop,
      shopify_order_id: payload.fetch("id").to_s,
      total_price: payload.fetch("total_price").to_d
    )
  end
end
