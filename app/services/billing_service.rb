class BillingService
  def initialize(shop)
    @shop = shop
    @api = ShopifyApiService.new(shop)
  end

  def create_subscription(plan_name:, price:, return_url:)
    mutation = <<~GRAPHQL
      mutation appSubscriptionCreate($name: String!, $returnUrl: URL!, $price: Decimal!, $test: Boolean!, $currency: CurrencyCode!) {
        appSubscriptionCreate(
          name: $name
          returnUrl: $returnUrl
          test: $test
          lineItems: [
            {
              plan: {
                appRecurringPricingDetails: {
                  price: { amount: $price, currencyCode: $currency }
                }
              }
            }
          ]
        ) {
          confirmationUrl
          appSubscription { id status name }
          userErrors { field message }
        }
      }
    GRAPHQL

    result = @api.graphql(
      query: mutation,
      variables: {
        name: plan_name,
        returnUrl: return_url,
        price: price.to_f,
        test: ENV.fetch("SHOPIFY_BILLING_TEST", "true") == "true",
        currency: ENV.fetch("BILLING_CURRENCY", "USD")
      }
    )

    data = result.body.dig("data", "appSubscriptionCreate")
    errors = data.fetch("userErrors")
    raise ShopifyApiService::ShopifyApiError, errors.first["message"] if errors.any?

    {
      confirmation_url: data.fetch("confirmationUrl"),
      charge: data.fetch("appSubscription")
    }
  end

  def fetch_subscription(charge_id)
    query = <<~GRAPHQL
      query appSubscription($id: ID!) {
        appSubscription(id: $id) {
          id
          status
          name
        }
      }
    GRAPHQL

    result = @api.graphql(query: query, variables: { id: charge_id })
    result.body.dig("data", "appSubscription")
  end
end
