class Subscription < ApplicationRecord
  belongs_to :shop

  validates :plan, :status, :shopify_charge_id, presence: true
  validates :shopify_charge_id, uniqueness: true
end
