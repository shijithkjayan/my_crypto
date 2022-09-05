defmodule MyCrypto.Messenger.HelpersTest do
  use ExUnit.Case

  alias MyCrypto.Messenger.Helpers

  @valid_params %{
    "entry" => [
      %{
        "id" => "108116478700104",
        "messaging" => [
          %{
            "message" => %{
              "mid" => "m_4gZFEvmCdPuGd4ok",
              "text" => "Hi"
            },
            "sender" => %{"id" => "538"},
            "timestamp" => 1_662_374_863_117
          }
        ]
      }
    ]
  }

  @invalid_params %{
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

  describe "get_message!/1" do
    test "retrieves the first message with valid data" do
      assert %{
               "message" => %{
                 "mid" => "m_4gZFEvmCdPuGd4ok",
                 "text" => "Hi"
               },
               "sender" => %{"id" => "538"},
               "timestamp" => 1_662_374_863_117
             } == Helpers.get_message!(@valid_params)
    end

    test "raises with invalid data" do
      assert_raise RuntimeError, "Invalid payload", fn ->
        Helpers.get_message!(@invalid_params)
      end
    end
  end

  describe "get_sender_id/1" do
    test "retrieves the sender's ID from the nested map" do
      params = %{"sender" => %{"id" => "538"}}
      assert "538" == Helpers.get_sender_id(params)
    end

    test "raises with invalid data" do
      assert_raise FunctionClauseError, fn ->
        Helpers.get_name_from_profile(%{"sender" => "538"})
      end
    end
  end

  describe "get_name_from_profile/1" do
    test "retrieves the first_name from the profile map" do
      params = %{
        "first_name" => "Test",
        "last_name" => "User",
        "id" => "123456",
        "profile_pic" => "www.example.com/test.png"
      }

      assert params["first_name"] == Helpers.get_name_from_profile(params)
    end

    test "raises with invalid data" do
      assert_raise FunctionClauseError, fn ->
        Helpers.get_name_from_profile(%{"last_name" => "User"})
      end
    end
  end
end
