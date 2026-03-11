class Shop < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :shopify_domain, presence: true, uniqueness: true
  validates :access_token, presence: true
  validates :installed_at, presence: true
end
