defmodule MyCrypto.Messenger.PayloadGenerator do
  @moduledoc """
  Helpers to generate response message body.
  """

  def initial_message_response(user_name, recipient_id) do
    message = "Hi #{user_name}! Welcome to MyCrypto. How would you like to search for coins?"

    message_body = %{
      attachment: %{
        type: "template",
        payload: %{
          template_type: "button",
          text: message,
          buttons: [
            %{
              type: "postback",
              title: "Search by coin name",
              payload: "search_by_name"
            },
            %{
              type: "postback",
              title: "Search by coin ID",
              payload: "search_by_id"
            }
          ]
        }
      }
    }

    message_response(message_body, recipient_id)
  end

  def get_coins_fail_response(recipient_id) do
    message = "We are unable to fetch the coins now, please try again later."
    message_response(%{text: message}, recipient_id)
  end

  def get_coins_success_response(coins, search_type, recipient_id) do
    quick_replies = Enum.map(coins, &generate_quick_reply_template(&1, search_type))

    message_body = %{
      text: "Select a coin",
      quick_replies: quick_replies
    }

    message_response(message_body, recipient_id)
  end

  defp generate_quick_reply_template(%{"id" => id} = coin, search_type) do
    %{
      content_type: "text",
      title: coin[search_type],
      payload: id
    }
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
