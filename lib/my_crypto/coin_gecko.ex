defmodule MyCrypto.CoinGecko do
  @moduledoc """
  The CoinGecko context module.
  """

  alias MyCrypto.CoinGecko.HttpClient

  @http_client Application.compile_env(:my_crypto, [__MODULE__, :http_client], HttpClient)

  @doc """
  Lists 5 random coins from the CoinGecko API response
  and
  """
  @spec list_coins :: list()
  def list_coins() do
    @http_client.list_coins() |> Enum.take_random(5)
  end

  def get_prices(coin_id) do
    case @http_client.get_market_chart(coin_id) do
      %{"prices" => prices} ->
        Enum.map(prices, fn [unix_time, price] ->
          date = unix_time |> DateTime.from_unix!(:millisecond) |> DateTime.to_date()
          "#{date}: #{price} \n\n"
        end)

      :error ->
        :error
    end
  end
end
