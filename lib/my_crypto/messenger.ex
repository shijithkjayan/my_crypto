defmodule MyCrypto.Messenger do
  @moduledoc """
  The Messenger context module.
  """

  alias MyCrypto.CoinGecko
  alias MyCrypto.Messenger.Helpers
  alias MyCrypto.Messenger.HttpClient
  alias MyCrypto.Messenger.PayloadGenerator

  @token System.get_env("MESSENGER_VERIFY_TOKEN")

  @doc """
  Validate the recieved token is same as what we have in the
  system. Returns true when its same and false otherwise.

  ## Examples

      iex> validate_verify_token("abcd")
      true

      iex> validate_verify_token(1234)
      false

  """
  @spec validate_verify_token(String.t()) :: boolean()
  def validate_verify_token(@token), do: true

  def validate_verify_token(_), do: false

  @doc """
  Reads the message and sends reply accordingly.
  """
  def read_message(payload) do
    message = Helpers.get_message!(payload)
    handle_message(message)
  end

  defp handle_message(%{"message" => %{"text" => text}} = message) when text in ["Hi", "Hello"] do
    sender_id = Helpers.get_sender_id(message)

    sender_id
    |> HttpClient.get_user_name()
    |> PayloadGenerator.initial_message_response(sender_id)
    |> HttpClient.send_reply()
  end

  defp handle_message(
         %{"message" => %{"quick_reply" => %{"payload" => "price_of_" <> coin_id}}} = message
       ) do
    sender_id = Helpers.get_sender_id(message)

    coin_id
    |> get_market_chart(sender_id)
    |> HttpClient.send_reply()
  end

  defp handle_message(%{"postback" => %{"payload" => "search_by_" <> type}} = message) do
    sender_id = Helpers.get_sender_id(message)

    sender_id
    |> get_coins(search_by: type)
    |> HttpClient.send_reply()
  end

  defp handle_message(message) do
    sender_id = Helpers.get_sender_id(message)

    sender_id
    |> HttpClient.get_user_name()
    |> PayloadGenerator.unknown_message_response(sender_id)
    |> HttpClient.send_reply()
  end

  defp get_coins(sender_id, search_by: search_type) do
    CoinGecko.list_coins()
    |> case do
      [] ->
        PayloadGenerator.get_coins_fail_response(sender_id)

      coins ->
        PayloadGenerator.get_coins_success_response(coins, search_type, sender_id)
    end
    |> HttpClient.send_reply()
  end

  defp get_market_chart(coin_id, sender_id) do
    coin_id
    |> CoinGecko.get_prices()
    |> PayloadGenerator.prices_response(sender_id)
    |> HttpClient.send_reply()
  end
end
