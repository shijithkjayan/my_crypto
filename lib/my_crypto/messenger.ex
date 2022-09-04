defmodule MyCrypto.Messenger do
  @moduledoc """
  The Messenger context module.
  """

  alias MyCrypto.Messenger.Helpers
  alias MyCrypto.Messenger.HttpClient

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

  defp handle_message(%{"message" => %{"text" => text}} = message)
       when text in ["hi", "Hi", "HI", "Hello", "hello", "HELLO"] do
    sender_id = Helpers.get_sender_id(message)
    user_name = HttpClient.get_user_name(sender_id)

    message = "Hi #{user_name}! Welcome to MyCrypto. How would you like to search for coins?"

    message_body = %{
      text: message,
      quick_replies: [
        %{
          content_type: "text",
          title: "Search by coin name",
          payload: "search_by_name"
        },
        %{
          content_type: "text",
          title: "Search by coin ID",
          payload: "search_by_id"
        }
      ]
    }

    message_body
    |> message_response(sender_id)
    |> HttpClient.send_reply()
  end

  defp handle_message(message) do
    IO.inspect(message)
    :error
  end

  defp message_response(message_body, recipient_id) do
    %{
      recipient: %{
        id: recipient_id
      },
      messaging_type: "RESPONSE",
      message: message_body
    }
  end
end
