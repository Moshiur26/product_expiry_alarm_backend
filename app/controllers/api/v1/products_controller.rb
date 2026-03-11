module Api
  module V1
    class ProductsController < ApplicationController
      before_action :require_shop!

      def index
        products = ShopifyApiService.new(current_shop).list_products
        render json: { products: products }
      end

      def sync
        products = ShopifyApiService.new(current_shop).sync_products
        render json: { products: products }
      end
    end
  end
end
