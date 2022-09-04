defmodule MyCrypto.CoinGecko.Http do
  @moduledoc """
  HTTP behaviour for CoinGecko HTTP Client.
  """

  @callback list_coins() :: list()
  @callback get_market_chart(String.t()) :: map()
end
