defmodule MyCrypto.IncomingMessageStructure do
  @moduledoc false
  def initial_message_payload(sender_id \\ "538") do
    %{
      "entry" => [
        %{
          "id" => "108116478700104",
          "messaging" => [
            %{
              "message" => %{
                "mid" => "m_4gZFEvmCdPuGd4ok",
                "text" => "Hi"
              },
              "sender" => %{"id" => sender_id},
              "timestamp" => 1_662_374_863_117
            }
          ]
        }
      ]
    }
  end

  def coin_price_message_payload(sender_id \\ "538") do
    %{
      "entry" => [
        %{
          "id" => "108116478700104",
          "messaging" => [
            %{
              "message" => %{
                "mid" => "m_4gZFEvmCdPuGd4ok",
                "quick_reply" => %{"payload" => "price_of_bitcoin"}
              },
              "sender" => %{"id" => sender_id},
              "timestamp" => 1_662_374_863_117
            }
          ]
        }
      ]
    }
  end

  def search_by_message_payload(type \\ "name", sender_id \\ "538") do
    %{
      "entry" => [
        %{
          "id" => "108116478700104",
          "messaging" => [
            %{
              "postback" => %{
                "mid" => "m_4gZFEvmCdPuGd4ok",
                "payload" => "search_by_" <> type
              },
              "sender" => %{"id" => sender_id},
              "timestamp" => 1_662_374_863_117
            }
          ]
        }
      ]
    }
  end

  def coin_search_keyword_message_payload(sender_id \\ "538") do
    %{
      "entry" => [
        %{
          "id" => "108116478700104",
          "messaging" => [
            %{
              "message" => %{
                "mid" => "m_4gZFEvmCdPuGd4ok",
                "text" => "bitcoin"
              },
              "sender" => %{"id" => sender_id},
              "timestamp" => 1_662_374_863_117
            }
          ]
        }
      ]
    }
  end
end
