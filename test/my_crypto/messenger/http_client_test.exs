defmodule MyCrypto.Messenger.HttpClientTest do
  use ExUnit.Case

  import Tesla.Mock
  import ExUnit.CaptureLog

  alias MyCrypto.Messenger.HttpClient

  @message %{
    recipient: %{
      id: "538"
    },
    messaging_type: "RESPONSE",
    message: %{
      text: "Thank you"
    }
  }

  setup do
    base_url = System.get_env("MESSENGER_URL")
    access_token = System.get_env("FB_PAGE_ACCESS_TOKEN")
    {:ok, %{base_url: base_url, access_token: access_token}}
  end

  describe "send_reply/1" do
    test "logs success message when the API call succeeds", %{
      base_url: base_url,
      access_token: token
    } do
      url = "#{base_url}/me/messages"

      mock(fn
        %{method: :post, url: ^url, query: [access_token: ^token], body: message} ->
          assert Jason.encode!(@message) == message
          %Tesla.Env{status: 200}
      end)

      # Changing log level so we can capture info logs
      Logger.configure(level: :debug)

      assert capture_log(fn ->
        assert :ok = HttpClient.send_reply(@message)
      end) =~ "Message send succesfully"

      # Reverting log level to avoid cluttering the test report with logs
      Logger.configure(level: :warn)
    end

    test "logs error message when the API call fails", %{base_url: base_url, access_token: token} do
      url = "#{base_url}/me/messages"

      mock(fn
        %{method: :post, url: ^url, query: [access_token: ^token], body: message} ->
          assert Jason.encode!(@message) == message
          {:error, :reason}
      end)

      assert capture_log(fn ->
               assert :ok = HttpClient.send_reply(@message)
             end) =~ "Failed to send message"
    end
  end

  describe "get_user_name/1" do
    test "returns first name of the user with valid ID", %{
      base_url: base_url,
      access_token: token
    } do
      sender_id = "123"
      url = "#{base_url}/#{sender_id}"

      mock(fn
        %{method: :get, url: ^url, query: [access_token: ^token]} ->
          %Tesla.Env{status: 200, body: %{"first_name" => "Test", "last_name" => "user"}}
      end)

      assert "Test" = HttpClient.get_user_name(sender_id)
    end

    test "returns \"there\" when the API call fails", %{base_url: base_url, access_token: token} do
      sender_id = "123"
      url = "#{base_url}/#{sender_id}"

      mock(fn
        %{method: :get, url: ^url, query: [access_token: ^token]} ->
          %Tesla.Env{status: 400, body: %{"error" => %{"code" => 100}}}
      end)

      assert capture_log(fn ->
               assert "there" = HttpClient.get_user_name(sender_id)
             end) =~ "Failed to get username"
    end
  end
end
