class Order < ApplicationRecord
  belongs_to :shop

  validates :shopify_order_id, presence: true
  validates :total_price, presence: true
end
