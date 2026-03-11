class ApplicationController < ActionController::API
  private

  def current_shop
    request.env["current_shop"]
  end

  def require_shop!
    render json: { error: "Unauthorized" }, status: :unauthorized if current_shop.nil?
  end
end
