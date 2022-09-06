defmodule MyCrypto.CoinGecko.HttpClient do
  @moduledoc """
  HTTP Client for Coin Gecko API calls
  """
  use Tesla
  require Logger

  @behaviour MyCrypto.CoinGecko.Http

  @vs_currency "usd"
  @days 14
  @interval "daily"

  plug Tesla.Middleware.BaseUrl, System.get_env("COINGECKO_URL")
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.PathParams

  def search_coins(keyword) do
    case get("/search", query: [query: keyword]) do
      {:ok, %Tesla.Env{body: %{"coins" => coins}, status: 200}} ->
        coins

      {:error, error} ->
        Logger.error("Coingecko coins/list API failed", error: error)
        :error
    end
  end

  def get_market_chart(coin_id) do
    opts = [path_params: [id: coin_id]]

    case get("/coins/:id/market_chart",
           opts: opts,
           query: [vs_currency: @vs_currency, days: @days, interval: @interval]
         ) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        body

      {:ok, %Tesla.Env{body: body}} ->
        Logger.error("Coingecko coins/:id/markert_chart API returned error", error: body)
        :error

      {:error, error} ->
        Logger.error("Coingecko coins/:id/markert_chart API failed", error: error)
        :error
    end
  end
end
