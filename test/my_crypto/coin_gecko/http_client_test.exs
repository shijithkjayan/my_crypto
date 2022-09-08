defmodule MyCrypto.CoinGecko.HttpClientTest do
  use ExUnit.Case

  import Tesla.Mock
  import ExUnit.CaptureLog

  alias MyCrypto.CoinGecko.HttpClient

  @search_result %{
    "coins" => [
      %{
        "id" => "solana",
        "name" => "Solana",
        "api_symbol" => "solana",
        "symbol" => "SOL",
        "market_cap_rank" => 9
      },
      %{
        "id" => "green-satoshi-token",
        "name" => "STEPN Green Satoshi Token on Solana",
        "api_symbol" => "green-satoshi-token",
        "symbol" => "GST-SOL",
        "market_cap_rank" => 697
      }
    ],
    "exchanges" => [],
    "icos" => [],
    "categories" => [
      %{
        "id" => 1,
        "name" => "Artificial Intelligence"
      },
      %{
        "id" => 2,
        "name" => "Augmented Reality"
      }
    ],
    "nfts" => [
      %{
        "id" => "everai-heroes-duo",
        "name" => "Everai Heroes: Duo",
        "symbol" => "EVERAIDUO"
      }
    ]
  }

  setup do
    base_url = System.get_env("COINGECKO_URL")
    {:ok, %{base_url: base_url}}
  end

  describe "search_coins/1" do
    test "returns coins matching the keyword", %{base_url: base_url} do
      keyword = "solana"

      url = "#{base_url}/search"

      mock(fn %{method: :get, url: ^url, query: [query: ^keyword]} ->
        %Tesla.Env{status: 200, body: @search_result}
      end)

      assert @search_result["coins"] == HttpClient.search_coins(keyword)
    end

    test "returns empty list when there are no matching coins", %{base_url: base_url} do
      keyword = "idontexist"

      url = "#{base_url}/search"

      mock(fn %{method: :get, url: ^url, query: [query: ^keyword]} ->
        %Tesla.Env{
          status: 200,
          body: %{
            "coins" => [],
            "exchanges" => [],
            "icos" => [],
            "categories" => [
              %{"id" => 1, "name" => "Artificial Intelligence"},
              %{"id" => 2, "name" => "Augmented Reality"}
            ],
            "nfts" => []
          }
        }
      end)

      assert [] == HttpClient.search_coins(keyword)
    end

    test "returns :error when API fails", %{base_url: base_url} do
      keyword = "solana"

      url = "#{base_url}/search"

      mock(fn %{method: :get, url: ^url, query: [query: ^keyword]} ->
        {:error, :reason}
      end)

      assert :error == HttpClient.search_coins(keyword)
    end

    test "logs error message when API fails", %{base_url: base_url} do
      keyword = "solana"

      url = "#{base_url}/search"

      mock(fn %{method: :get, url: ^url, query: [query: ^keyword]} ->
        {:error, :reason}
      end)

      assert capture_log(fn ->
               assert :error == HttpClient.search_coins(keyword)
             end) =~ "Coingecko Search API failed"
    end
  end

  describe "get_market_chart/1" do
    test "returns the market chart of the coin with valid ID", %{base_url: base_url} do
      coin_id = "bitcoin"
      vs_currency = "usd"
      days = 14
      interval = "daily"

      prices = [[1_661_126_400_000, 21615.761693416986], [1_661_212_800_000, 21387.747114773963]]

      url = "#{base_url}/coins/#{coin_id}/market_chart"

      mock(fn
        %{
          method: :get,
          url: ^url,
          query: [vs_currency: ^vs_currency, days: ^days, interval: ^interval],
          opts: [path_params: [id: ^coin_id]]
        } ->
          %Tesla.Env{
            status: 200,
            body: %{
              "prices" => prices,
              "market_caps" => [],
              "toal_volume" => []
            }
          }
      end)

      assert %{"prices" => ^prices} = HttpClient.get_market_chart(coin_id)
    end

    test "returns the :error with invalid ID", %{base_url: base_url} do
      coin_id = "invalid"
      url = "#{base_url}/coins/#{coin_id}/market_chart"

      mock(fn
        %{method: :get, url: ^url} ->
          %Tesla.Env{
            status: 404,
            body: %{"error" => "Could not find coin with the given id"}
          }
      end)

      assert capture_log(fn ->
               assert :error = HttpClient.get_market_chart(coin_id)
             end) =~ "Coingecko Market Chart API returned error"
    end

    test "returns the :error when the API fails", %{base_url: base_url} do
      coin_id = "bitcoin"
      url = "#{base_url}/coins/#{coin_id}/market_chart"

      mock(fn
        %{method: :get, url: ^url} -> {:error, :reason}
      end)

      assert capture_log(fn ->
               assert :error = HttpClient.get_market_chart(coin_id)
             end) =~ "Coingecko Market Chart API failed"
    end
  end
end
