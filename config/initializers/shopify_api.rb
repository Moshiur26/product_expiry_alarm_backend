ShopifyAPI::Context.setup(
  api_key: ENV.fetch("SHOPIFY_API_KEY"),
  api_secret_key: ENV.fetch("SHOPIFY_API_SECRET"),
  scope: ENV.fetch("SHOPIFY_SCOPES", "read_products,write_products,read_orders"),
  host_name: ENV.fetch("HOST_NAME", ""),
  api_version: ENV.fetch("SHOPIFY_API_VERSION", "2024-10"),
  is_embedded: true,
  is_private: false
)
