defmodule MyCrypto.CoinGecko do
  @moduledoc """
  The CoinGecko context module.
  """

  alias MyCrypto.CoinGecko.HttpClient

  @doc """
  Lists 5 random coins from the CoinGecko API response
  and
  """
  @spec list_coins :: list()
  def list_coins() do
    HttpClient.list_coins() |> Enum.take_random(5)
  end
end