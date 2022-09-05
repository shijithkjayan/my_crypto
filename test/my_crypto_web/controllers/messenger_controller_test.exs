defmodule MyCryptoWeb.MessengerControllerTest do
  use MyCryptoWeb.ConnCase

  import Mox
  setup :verify_on_exit!

  alias MyCrypto.Messenger.HttpClientMock, as: MessengerClientMock

  @sender_id "1234567890"

  @valid_message %{
    "entry" => [
      %{
        "messaging" => [
          %{
            "message" => %{"text" => "Hi"},
            "sender" => %{"id" => @sender_id}
          }
        ]
      }
    ]
  }

  @invalid_message %{"entry" => %{"invalid" => "should fail"}}

  setup do
    {:ok, %{verify_token: System.get_env("MESSENGER_VERIFY_TOKEN")}}
  end

  describe "GET validate/2" do
    test "returns the hub.challenge value with valid params", %{
      conn: conn,
      verify_token: verify_token
    } do
      conn =
        get(
          conn,
          Routes.messenger_path(conn, :validate,
            "hub.mode": "subscribe",
            "hub.challenge": 1234,
            "hub.verify_token": verify_token
          )
        )

      assert 1234 = json_response(conn, 200)
    end

    test "returns error with invalid verify_token", %{conn: conn} do
      conn =
        get(
          conn,
          Routes.messenger_path(conn, :validate,
            "hub.mode": "subscribe",
            "hub.challenge": 1234,
            "hub.verify_token": "invalid"
          )
        )

      assert %{"status" => "error", "message" => "invalid payload"} = json_response(conn, 422)
    end

    test "returns error with invalid hub.mode value", %{conn: conn, verify_token: verify_token} do
      conn =
        get(
          conn,
          Routes.messenger_path(conn, :validate,
            "hub.mode": "invalid",
            "hub.challenge": 1234,
            "hub.verify_token": verify_token
          )
        )

      assert %{"status" => "error", "message" => "invalid payload"} = json_response(conn, 422)
    end
  end

  describe "POST recieve_message/2" do
    test "returns success response with valid params", %{conn: conn} do
      MessengerClientMock
      |> expect(:send_reply, fn _ -> {:ok, %Tesla.Env{body: %{}}} end)
      |> expect(:get_user_name, fn @sender_id -> "TestUser" end)

      conn = post(conn, Routes.messenger_path(conn, :recieve_message), @valid_message)
      assert %{"status" => "ok"} == json_response(conn, 200)
    end

    test "raises with invalid params", %{conn: conn} do
      assert_raise RuntimeError, "Invalid payload", fn ->
        post(conn, Routes.messenger_path(conn, :recieve_message), @invalid_message)
      end
    end
  end
end
