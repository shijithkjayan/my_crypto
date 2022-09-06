defmodule MyCrypto.CoinGeckoTest do
  use ExUnit.Case

  import Mox
  setup :verify_on_exit!

  alias MyCrypto.CoinGecko
  alias MyCrypto.CoinGecko.HttpClientMock

  describe "get_prices/1" do
    test "returns the readable dates and formats prices on that dates for the" <>
           "given coin ID when API call succeeds" do
      coin_id = "bitcoin"
      unix_dt1 = 1_661_126_400_000
      unix_dt2 = 1_661_212_800_000
      price1 = 21615.761693416986
      price2 = 21387.747114773963

      date1 = convert_unix_to_date(unix_dt1)
      date2 = convert_unix_to_date(unix_dt2)
      usd1 = format_price(price1)
      usd2 = format_price(price2)

      expect(HttpClientMock, :get_market_chart, fn ^coin_id ->
        %{
          "prices" => [
            [unix_dt1, price1],
            [unix_dt2, price2]
          ]
        }
      end)

      assert ["#{date1}: #{usd1} \n\n", "#{date2}: #{usd2} \n\n"] ==
               CoinGecko.get_prices(coin_id)
    end

    test "prices has a precision of 10" do
      coin_id = "bitcoin"
      unix_dt = 1_661_126_400_000
      price = 21615.761693416986

      date = convert_unix_to_date(unix_dt)
      usd = format_price(price)

      expect(HttpClientMock, :get_market_chart, fn ^coin_id ->
        %{
          "prices" => [
            [unix_dt, price]
          ]
        }
      end)

      assert ["#{date}: #{usd} \n\n"] ==
               CoinGecko.get_prices(coin_id)
      assert 10 == usd |> String.split(".") |> List.last() |> String.length
    end

    test "prices has USD unit" do
      coin_id = "bitcoin"
      unix_dt = 1_661_126_400_000
      price = 21615.761693416986

      date = convert_unix_to_date(unix_dt)
      usd = format_price(price)

      expect(HttpClientMock, :get_market_chart, fn ^coin_id ->
        %{
          "prices" => [
            [unix_dt, price]
          ]
        }
      end)

      assert ["#{date}: #{usd} \n\n"] ==
               CoinGecko.get_prices(coin_id)
      assert "$" <> _ = usd
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

  defp format_price(price), do: Number.Currency.number_to_currency(price)
end
