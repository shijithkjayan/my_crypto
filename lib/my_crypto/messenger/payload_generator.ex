defmodule MyCrypto.Messenger.PayloadGenerator do
  @moduledoc """
  Helpers to generate response message body.
  """

  def initial_message_response(user_name, recipient_id) do
    message = "Hi #{user_name}! Welcome to MyCrypto.\n How would you like to search for coins?"

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

  def search_results(:error, recipient_id) do
    message = "We are unable to fetch the coins now, please try again later."
    message_response(%{text: message}, recipient_id)
  end

  def search_results([], recipient_id) do
    message_body = %{
      text: "No coins found.! Please try another keyword"
    }

    message_response(message_body, recipient_id)
  end

  def search_results(coins, recipient_id) do
    quick_replies = Enum.map(coins, &generate_quick_reply_template(&1))

    message_body = %{
      text: "Select a coin",
      quick_replies: quick_replies
    }

    message_response(message_body, recipient_id)
  end

  defp generate_quick_reply_template(%{"id" => id, "name" => name}) do
    %{
      content_type: "text",
      title: name,
      payload: "price_of_#{id}"
    }
  end

  def prices_response(:error, recipient_id) do
    message = "We are unable to fetch the prices now, please try again later."
    message_response(%{text: message}, recipient_id)
  end

  def prices_response(prices, recipient_id) do
    message = """
    The price of requested coin over the last 14 days is:

    #{prices}
    """

    message_response(%{text: message}, recipient_id)
  end

  def search_by_response(type, recipient_id) do
    message = """
    Enter the coin #{type} keyword to search
    """

    message_response(%{text: message}, recipient_id)
  end

  def unknown_message_response(user_name, recipient_id) do
    message = """
    I am sorry #{user_name}, I did not understand your request. \n
    You may please start the conversation by sending `Hi` or `Hello` or \n
    please wait for one of our executes to respond back to you.! Thank you
    """

    message_response(%{text: message}, recipient_id)
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
