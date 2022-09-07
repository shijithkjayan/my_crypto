defmodule MyCrypto.MessengerTest do
  use ExUnit.Case

  import Mox
  import MyCrypto.IncomingMessageStructure
  import MyCrypto.OutgoingMessageStructure

  setup :verify_on_exit!

  alias MyCrypto.CoinGecko.HttpClientMock, as: CoinGeckoHttpClient
  alias MyCrypto.Messenger
  alias MyCrypto.Messenger.HttpClientMock, as: MessengerHttpClient

  @ets_table Application.compile_env(:my_crypto, :ets_table, :sender_state)

  describe "validate_verify_token/1" do
    test "returns true when params matches the messenger verify token" do
      token = System.get_env("MESSENGER_VERIFY_TOKEN")

      assert Messenger.validate_verify_token(token)
    end

    test "returns fals when params doesnt match the messenger verify token" do
      token = "invalid_token"

      refute Messenger.validate_verify_token(token)
    end
  end

  describe "read_message/1" do
    setup do
      :ets.delete_all_objects(@ets_table)
      :ok
    end

    test "raises with invalid payload" do
      payload = %{
        "entry" => [
          %{
            "id" => "108116478700104",
            "messaging" => %{
              "message" => %{
                "text" => "INVALID MESSAGE"
              },
              "sender" => %{"id" => "538"},
              "timestamp" => 1_662_374_863_117
            }
          }
        ]
      }

      assert_raise RuntimeError, "Invalid payload", fn ->
        Messenger.read_message(payload)
      end
    end

    test "sends reply and returns :ok for initial message payload" do
      message = initial_message_payload("123456")
      response = initial_response_payload("Test", "123456")

      MessengerHttpClient
      |> expect(:get_user_name, fn "123456" -> "Test" end)
      |> expect(:send_reply, fn ^response -> :ok end)

      assert :ok = Messenger.read_message(message)
    end

    test "sets the state of the sender as \"initial\" after initial message" do
      message = initial_message_payload("123")
      response = initial_response_payload("Test", "123")

      MessengerHttpClient
      |> expect(:get_user_name, fn "123" -> "Test" end)
      |> expect(:send_reply, fn ^response -> :ok end)

      assert :ok = Messenger.read_message(message)

      assert [{"123", "initial", _}] = :ets.lookup(@ets_table, "123")
    end

    test "sends reply and returns :ok for search_by_name payload" do
      message = search_by_message_payload()
      response = search_by_response_payload()

      expect(MessengerHttpClient, :send_reply, fn ^response -> :ok end)

      assert :ok = Messenger.read_message(message)
    end

    test "sends reply and returns :ok for search_by_id payload" do
      message = search_by_message_payload("id")
      response = search_by_response_payload("id")

      expect(MessengerHttpClient, :send_reply, fn ^response -> :ok end)

      assert :ok = Messenger.read_message(message)
    end

    test "sets the state of the sender as \"search_by\" after search_by message" do
      message = search_by_message_payload("id")
      response = search_by_response_payload("id")

      expect(MessengerHttpClient, :send_reply, fn ^response -> :ok end)

      assert :ok = Messenger.read_message(message)
      assert [{"538", "search_by", _}] = :ets.lookup(@ets_table, "538")
    end

    test "sends reply and returns :ok for search payload when search has results" do
      message = coin_search_keyword_message_payload()
      response = search_success_response_payload()

      # Set user's state
      :ets.insert(@ets_table, {"538", "search_by", DateTime.add(DateTime.utc_now(), 60)})

      expect(MessengerHttpClient, :send_reply, fn ^response -> :ok end)

      expect(CoinGeckoHttpClient, :search_coins, fn "bitcoin" ->
        [
          %{"id" => "bitcoin", "name" => "Bitcoin"},
          %{"id" => "wrapped-bitcoin", "name" => "Wrapped Bitcoin"}
        ]
      end)

      assert :ok = Messenger.read_message(message)
    end

    test "sends reply and returns :ok for search payload when search has empty results" do
      message = coin_search_keyword_message_payload()
      response = search_empty_response_payload()

      # Set user's state
      :ets.insert(@ets_table, {"538", "search_by", DateTime.add(DateTime.utc_now(), 60)})

      expect(MessengerHttpClient, :send_reply, fn ^response -> :ok end)
      expect(CoinGeckoHttpClient, :search_coins, fn _ -> [] end)

      assert :ok = Messenger.read_message(message)
    end

    test "sends reply and returns :ok for search payload when search fails" do
      message = coin_search_keyword_message_payload()
      response = search_error_response_payload()

      # Set user's state
      :ets.insert(@ets_table, {"538", "search_by", DateTime.add(DateTime.utc_now(), 60)})

      expect(MessengerHttpClient, :send_reply, fn ^response -> :ok end)
      expect(CoinGeckoHttpClient, :search_coins, fn _ -> :error end)

      assert :ok = Messenger.read_message(message)
    end

    test "resets the state of the sender as \"search_by\" after search message when the current state is \"search_by\"" do
      message = coin_search_keyword_message_payload()
      response = search_error_response_payload()

      # Set user's state
      expiry = DateTime.add(DateTime.utc_now(), 60)
      :ets.insert(@ets_table, {"538", "search_by", expiry})

      expect(MessengerHttpClient, :send_reply, fn ^response -> :ok end)
      expect(CoinGeckoHttpClient, :search_coins, fn _ -> :error end)

      assert :ok = Messenger.read_message(message)
      assert [{"538", "search_by", new_expiry}] = :ets.lookup(@ets_table, "538")

      assert :gt = DateTime.compare(new_expiry, expiry)
    end

    test "sends unknown message response when user has no state set" do
      message = coin_search_keyword_message_payload()
      response = unkown_message_response_payload("Test")

      MessengerHttpClient
      |> expect(:get_user_name, fn "538" -> "Test" end)
      |> expect(:send_reply, fn ^response -> :ok end)

      assert :ok = Messenger.read_message(message)
    end

    test "sends unknown message response when user's state is not \"search_by\"" do
      message = coin_search_keyword_message_payload()
      response = unkown_message_response_payload("Test")

      # Set user's state
      expiry = DateTime.add(DateTime.utc_now(), 60)
      :ets.insert(@ets_table, {"538", "initial", expiry})

      MessengerHttpClient
      |> expect(:get_user_name, fn "538" -> "Test" end)
      |> expect(:send_reply, fn ^response -> :ok end)

      assert :ok = Messenger.read_message(message)
    end

    test "sends unknown message response when user's state is expired" do
      message = coin_search_keyword_message_payload()
      response = unkown_message_response_payload("Test")

      # Set user's state with past expiry time
      expiry = DateTime.add(DateTime.utc_now(), -60)
      :ets.insert(@ets_table, {"538", "initial", expiry})

      MessengerHttpClient
      |> expect(:get_user_name, fn "538" -> "Test" end)
      |> expect(:send_reply, fn ^response -> :ok end)

      assert :ok = Messenger.read_message(message)
    end

    test "sends unknown message response and deletes user's state" do
      message = coin_search_keyword_message_payload()
      response = unkown_message_response_payload("Test")

      # Set user's state with past expiry time
      expiry = DateTime.add(DateTime.utc_now(), -60)
      :ets.insert(@ets_table, {"538", "initial", expiry})

      MessengerHttpClient
      |> expect(:get_user_name, fn "538" -> "Test" end)
      |> expect(:send_reply, fn ^response -> :ok end)

      assert :ok = Messenger.read_message(message)
      assert [] = :ets.lookup(@ets_table, "538")
    end

    test "sends reply and returns :ok for coin price payload when prices are available" do
      message = coin_price_message_payload()
      response = coin_price_sucess_response_payload()

      expect(MessengerHttpClient, :send_reply, fn ^response ->
        :ok
      end)

      expect(CoinGeckoHttpClient, :get_market_chart, fn "bitcoin" ->
        %{
          "prices" => [
            [1_661_385_600_000, 55.53934216177411],
            [1_661_472_000_000, 55.78616391173912],
            [1_661_558_400_000, 52.23850761016998],
            [1_661_644_800_000, 52.46444951277418],
            [1_661_731_200_000, 52.313526268897164],
            [1_661_817_600_000, 53.91289627998253],
            [1_661_904_000_000, 52.0810246146821],
            [1_661_990_400_000, 51.95906858425384],
            [1_662_076_800_000, 52.51953538184408],
            [1_662_163_200_000, 53.75117342588125],
            [1_662_249_600_000, 52.51426731850548],
            [1_662_336_000_000, 53.3184743386411],
            [1_662_422_400_000, 53.560964888822085],
            [1_662_508_800_000, 49.6785825528356],
            [1_662_548_920_000, 50.02110436235209]
          ]
        }
      end)

      assert :ok = Messenger.read_message(message)
    end

    test "sends reply and returns :ok for coin price payload when prices are NOT available" do
      message = coin_price_message_payload()
      response = coin_price_error_response_payload()

      expect(MessengerHttpClient, :send_reply, fn ^response -> :ok end)
      expect(CoinGeckoHttpClient, :get_market_chart, fn "bitcoin" -> :error end)

      assert :ok = Messenger.read_message(message)
    end

    test "sends reply and deletes user's state" do
      message = coin_price_message_payload()
      response = coin_price_sucess_response_payload()

      # Set user's state with past expiry time
      expiry = DateTime.add(DateTime.utc_now(), -60)
      :ets.insert(@ets_table, {"538", "search_by", expiry})

      expect(MessengerHttpClient, :send_reply, fn ^response ->
        :ok
      end)

      expect(CoinGeckoHttpClient, :get_market_chart, fn "bitcoin" ->
        %{
          "prices" => [
            [1_661_385_600_000, 55.53934216177411],
            [1_661_472_000_000, 55.78616391173912],
            [1_661_558_400_000, 52.23850761016998],
            [1_661_644_800_000, 52.46444951277418],
            [1_661_731_200_000, 52.313526268897164],
            [1_661_817_600_000, 53.91289627998253],
            [1_661_904_000_000, 52.0810246146821],
            [1_661_990_400_000, 51.95906858425384],
            [1_662_076_800_000, 52.51953538184408],
            [1_662_163_200_000, 53.75117342588125],
            [1_662_249_600_000, 52.51426731850548],
            [1_662_336_000_000, 53.3184743386411],
            [1_662_422_400_000, 53.560964888822085],
            [1_662_508_800_000, 49.6785825528356],
            [1_662_548_920_000, 50.02110436235209]
          ]
        }
      end)

      assert :ok = Messenger.read_message(message)
      assert [] = :ets.lookup(@ets_table, "538")
    end
  end
end
