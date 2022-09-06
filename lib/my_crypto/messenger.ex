defmodule MyCrypto.Messenger do
  @moduledoc """
  The Messenger context module.
  """

  alias MyCrypto.CoinGecko
  alias MyCrypto.Messenger.Helpers
  alias MyCrypto.Messenger.HttpClient
  alias MyCrypto.Messenger.PayloadGenerator

  @http_client Application.compile_env(:my_crypto, [__MODULE__, :http_client], HttpClient)

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
  def validate_verify_token(token) do
    System.get_env("MESSENGER_VERIFY_TOKEN") == token
  end

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
    |> @http_client.get_user_name()
    |> PayloadGenerator.initial_message_response(sender_id)
    |> @http_client.send_reply()
  end

  defp handle_message(
         %{"message" => %{"quick_reply" => %{"payload" => "price_of_" <> coin_id}}} = message
       ) do
    sender_id = Helpers.get_sender_id(message)

    coin_id
    |> CoinGecko.get_prices()
    |> PayloadGenerator.prices_response(sender_id)
    |> @http_client.send_reply()
  end

  defp handle_message(%{"postback" => %{"payload" => "search_by_" <> type}} = message) do
    sender_id = Helpers.get_sender_id(message)

    type
    |> PayloadGenerator.search_by_response(sender_id)
    |> @http_client.send_reply()
  end

  defp handle_message(%{"message" => %{"text" => text}} = message) do
    message
    |> Helpers.get_sender_id()
    |> get_coins_payload(text)
    |> @http_client.send_reply()
  end

  defp handle_message(message) do
    sender_id = Helpers.get_sender_id(message)

    sender_id
    |> @http_client.get_user_name()
    |> PayloadGenerator.unknown_message_response(sender_id)
    |> @http_client.send_reply()
  end

  defp get_coins_payload(sender_id, keyword) do
    keyword
    |> CoinGecko.search_coins()
    |> PayloadGenerator.search_results(sender_id)
  end
end
