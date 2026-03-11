require "net/http"
require "uri"

class ShopifyApiService
  class ShopifyApiError < StandardError; end

  def self.exchange_access_token(shop_domain, code)
    uri = URI("https://#{shop_domain}/admin/oauth/access_token")
    response = Net::HTTP.post_form(
      uri,
      {
        client_id: ENV.fetch("SHOPIFY_API_KEY"),
        client_secret: ENV.fetch("SHOPIFY_API_SECRET"),
        code: code
      }
    )

    unless response.is_a?(Net::HTTPSuccess)
      raise ShopifyApiError, "Failed to exchange access token"
    end

    body = JSON.parse(response.body)
    body.fetch("access_token")
  end

  def initialize(shop)
    @shop = shop
  end

  def list_products(limit: 50)
    rest_client.get(path: "products", query: { limit: limit }).body.fetch("products")
  end

  def sync_products(limit: 50)
    list_products(limit: limit)
  end

  def graphql(query:, variables: {})
    graphql_client.query(query: query, variables: variables)
  end

  private

  def rest_client
    @rest_client ||= ShopifyAPI::Clients::Rest.new(shop: @shop.shopify_domain, access_token: @shop.access_token)
  end

  def graphql_client
    @graphql_client ||= ShopifyAPI::Clients::Graphql.new(shop: @shop.shopify_domain, access_token: @shop.access_token)
  end
end
