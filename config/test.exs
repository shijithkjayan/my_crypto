import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :my_crypto, MyCryptoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "jYsJW7fUsY37+p+QbxhJuvuroYbxQgurehf00IHZxRJWa4wbVkDu4Vb2nc/y1pmX",
  server: false

config :my_crypto, MyCrypto.CoinGecko, http_client: MyCrypto.CoinGecko.HttpClientMock
config :my_crypto, MyCrypto.Messenger, http_client: MyCrypto.Messenger.HttpClientMock

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
