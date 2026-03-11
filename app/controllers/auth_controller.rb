require "cgi"
require "securerandom"

class AuthController < ApplicationController
  def auth
    shop = params[:shop]
    return render json: { error: "Missing shop parameter" }, status: :bad_request if shop.blank?

    state = SecureRandom.hex(16)
    Rails.cache.write(state_cache_key(state), true, expires_in: 10.minutes)

    redirect_uri = ENV.fetch("SHOPIFY_REDIRECT_URI", "#{request.base_url}/auth/callback")
    scopes = ENV.fetch("SHOPIFY_SCOPES", "read_products,write_products,read_orders")

    install_url = "https://#{shop}/admin/oauth/authorize?" \
                  "client_id=#{ENV.fetch("SHOPIFY_API_KEY")}&" \
                  "scope=#{CGI.escape(scopes)}&" \
                  "redirect_uri=#{CGI.escape(redirect_uri)}&" \
                  "state=#{state}&" \
                  "grant_options[]=per-user"

    redirect_to install_url, allow_other_host: true
  end

  def callback
    return render json: { error: "Invalid HMAC" }, status: :unauthorized unless valid_hmac?

    state = params[:state]
    unless Rails.cache.read(state_cache_key(state))
      return render json: { error: "Invalid state" }, status: :unauthorized
    end
    Rails.cache.delete(state_cache_key(state))

    shop = params[:shop]
    code = params[:code]

    access_token = ShopifyApiService.exchange_access_token(shop, code)
    shop_record = Shop.find_or_initialize_by(shopify_domain: shop)
    shop_record.access_token = access_token
    shop_record.installed_at = Time.current
    shop_record.save!

    render json: { ok: true }
  rescue ShopifyApiService::ShopifyApiError => e
    render json: { error: e.message }, status: :bad_gateway
  end

  private

  def valid_hmac?
    hmac = params[:hmac].to_s
    query_params = request.query_parameters.except(:hmac, :signature)
    message = query_params.sort.map { |key, value| "#{key}=#{value}" }.join("&")
    digest = OpenSSL::HMAC.hexdigest("sha256", ENV.fetch("SHOPIFY_API_SECRET"), message)
    ActiveSupport::SecurityUtils.secure_compare(digest, hmac)
  end

  def state_cache_key(state)
    "shopify_oauth_state:#{state}"
  end
end
