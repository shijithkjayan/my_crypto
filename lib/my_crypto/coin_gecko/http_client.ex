defmodule MyCrypto.CoinGecko.HttpClient do
  use Tesla
  require Logger

  @base_url System.get_env("COINGECKO_URL")

  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.JSON

  def list_coins() do
    case get("/coins/list") do
      {:ok, %Tesla.Env{body: body}} ->
        body

      {:error, error} ->
        Logger.error("Coingecko coins/list API failed", error: error)
        []
    end
  end
end
