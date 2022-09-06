defmodule MyCrypto.CoinGecko.Http do
  @moduledoc """
  HTTP behaviour for CoinGecko HTTP Client.
  """

  @callback search_coins(String.t()) :: list()
  @callback get_market_chart(String.t()) :: map()
end
