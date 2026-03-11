require "jwt"
require "uri"

module Middleware
  class ShopifyJwtMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      if request.path.start_with?("/api/v1") || request.path.start_with?("/billing")
        token = bearer_token(request)
        return unauthorized unless token

        payload = decode_token(token)
        return unauthorized unless payload

        shop_domain = extract_shop_domain(payload)
        shop = Shop.find_by(shopify_domain: shop_domain)
        return unauthorized unless shop

        env["current_shop"] = shop
      end

      @app.call(env)
    end

    private

    def bearer_token(request)
      header = request.get_header("HTTP_AUTHORIZATION")
      return nil if header.nil?

      scheme, token = header.split(" ", 2)
      return nil unless scheme == "Bearer"

      token
    end

    def decode_token(token)
      JWT.decode(
        token,
        ENV.fetch("SHOPIFY_API_SECRET"),
        true,
        {
          algorithm: "HS256",
          verify_aud: true,
          aud: ENV.fetch("SHOPIFY_API_KEY")
        }
      ).first
    rescue JWT::DecodeError
      nil
    end

    def extract_shop_domain(payload)
      url = payload["dest"] || payload["iss"]
      return nil if url.nil?

      URI.parse(url).host
    rescue URI::InvalidURIError
      nil
    end

    def unauthorized
      [401, { "Content-Type" => "application/json" }, [{ error: "Unauthorized" }.to_json]]
    end
  end
end
