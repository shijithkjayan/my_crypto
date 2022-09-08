defmodule MyCrypto.OutgoingMessageStructure do
  @moduledoc false
  def initial_response_payload(user_name \\ "there", recipient_id \\ "538") do
    %{
      recipient: %{
        id: recipient_id
      },
      messaging_type: "RESPONSE",
      message: %{
        attachment: %{
          type: "template",
          payload: %{
            template_type: "button",
            text:
              "Hi #{user_name}! Welcome to MyCrypto.\n How would you like to search for coins?",
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
    }
  end

  def coin_price_sucess_response_payload(recipient_id \\ "538") do
    %{
      recipient: %{
        id: recipient_id
      },
      messaging_type: "RESPONSE",
      message: %{
        text: """
        The price of requested coin over the last 14 days are:

        2022-08-25: $55.5393421618 \n
        2022-08-26: $55.7861639117 \n
        2022-08-27: $52.2385076102 \n
        2022-08-28: $52.4644495128 \n
        2022-08-29: $52.3135262689 \n
        2022-08-30: $53.9128962800 \n
        2022-08-31: $52.0810246147 \n
        2022-09-01: $51.9590685843 \n
        2022-09-02: $52.5195353818 \n
        2022-09-03: $53.7511734259 \n
        2022-09-04: $52.5142673185 \n
        2022-09-05: $53.3184743386 \n
        2022-09-06: $53.5609648888 \n
        2022-09-07: $49.6785825528 \n
        2022-09-07: $50.0211043624 \n\n
        """
      }
    }
  end

  def coin_price_error_response_payload(recipient_id \\ "538") do
    %{
      recipient: %{id: recipient_id},
      messaging_type: "RESPONSE",
      message: %{text: "We are unable to fetch the prices now, please try again later."}
    }
  end

  def search_by_response_payload(type \\ "name", recipient_id \\ "538") do
    %{
      recipient: %{id: recipient_id},
      messaging_type: "RESPONSE",
      message: %{
        text: """
        Enter the coin #{type} keyword to search
        """
      }
    }
  end

  def search_error_response_payload(recipient_id \\ "538") do
    %{
      recipient: %{id: recipient_id},
      messaging_type: "RESPONSE",
      message: %{text: "We are unable to fetch the coins now, please try again later."}
    }
  end

  def search_empty_response_payload(recipient_id \\ "538") do
    %{
      recipient: %{id: recipient_id},
      messaging_type: "RESPONSE",
      message: %{text: "No coins found! Please try another keyword"}
    }
  end

  def search_success_response_payload(recipient_id \\ "538") do
    %{
      recipient: %{
        id: recipient_id
      },
      messaging_type: "RESPONSE",
      message: %{
        text: "Select a coin",
        quick_replies: [
          %{
            content_type: "text",
            title: "Bitcoin",
            payload: "price_of_bitcoin"
          },
          %{
            content_type: "text",
            title: "Wrapped Bitcoin",
            payload: "price_of_wrapped-bitcoin"
          }
        ]
      }
    }
  end

  def unkown_message_response_payload(user_name \\ "there", recipient_id \\ "538") do
    %{
      recipient: %{id: recipient_id},
      messaging_type: "RESPONSE",
      message: %{
        text: """
        I am sorry #{user_name}, I did not understand your request. \n
        You may please start the conversation by sending `Hi` or `Hello`. \n
        Thank you
        """
      }
    }
  end
end
