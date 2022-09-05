defmodule MyCrypto.CoinGeckoTest do
  use ExUnit.Case

  import Mox
  setup :verify_on_exit!

  alias MyCrypto.CoinGecko
  alias MyCrypto.CoinGecko.HttpClientMock

  describe "get_prices/1" do
    test "returns the readable dates and prices on that dates for the" <>
           "given coin ID when API call succeeds" do
      coin_id = "bitcoin"
      unix_dt1 = 1_661_126_400_000
      unix_dt2 = 1_661_212_800_000
      price1 = 21615.761693416986
      price2 = 21387.747114773963

      date1 = convert_unix_to_date(unix_dt1)
      date2 = convert_unix_to_date(unix_dt2)

      expect(HttpClientMock, :get_market_chart, fn ^coin_id ->
        %{
          "prices" => [
            [unix_dt1, price1],
            [unix_dt2, price2]
          ]
        }
      end)

      assert ["#{date1}: #{price1} \n\n", "#{date2}: #{price2} \n\n"] ==
               CoinGecko.get_prices(coin_id)
    end

    test "returns :error with invalid coin ID" do
      coin_id = "btcoin"

      expect(HttpClientMock, :get_market_chart, fn ^coin_id ->
        :error
      end)

      assert :error = CoinGecko.get_prices(coin_id)
    end

    test "returns :error when API fails" do
      coin_id = "bitcoin"

      expect(HttpClientMock, :get_market_chart, fn ^coin_id ->
        :error
      end)

      assert :error = CoinGecko.get_prices(coin_id)
    end
  end

  # Helpers

  defp convert_unix_to_date(unix_dt) do
    unix_dt |> DateTime.from_unix!(:millisecond) |> DateTime.to_date()
  end
end
