defmodule MyCrypto.CoinGecko do
  @moduledoc """
  The CoinGecko context module.
  """

  alias MyCrypto.CoinGecko.HttpClient

  @http_client Application.compile_env(:my_crypto, [__MODULE__, :http_client], HttpClient)

  @doc """
  Gets the top 5 coins in terms of market cap that matches the keyword.
  """
  @spec search_coins(String.t()) :: list()
  def search_coins(keyword) do
    keyword
    |> @http_client.search_coins()
    |> case do
      :error ->
        :error

      coins ->
        Enum.slice(coins, 0, 5)
    end
  end

  def get_prices(coin_id) do
    case @http_client.get_market_chart(coin_id) do
      %{"prices" => prices} ->
        Enum.map(prices, fn [unix_time, price] ->
          date = unix_time |> DateTime.from_unix!(:millisecond) |> DateTime.to_date()
          price = Number.Currency.number_to_currency(price)
          "#{date}: #{price} \n\n"
        end)

      :error ->
        :error
    end
  end
end
