defmodule MyCrypto.Messenger.HttpClient do
  @moduledoc """
  HTTP Client for Graph API calls
  """
  use Tesla
  require Logger

  @behaviour MyCrypto.Messenger.Http

  plug Tesla.Middleware.BaseUrl, System.get_env("MESSENGER_URL")
  plug Tesla.Middleware.JSON

  alias MyCrypto.Messenger.Helpers

  def send_reply(body) do
    case post("/me/messages", body, query: [access_token: access_token()]) do
      {:ok, %Tesla.Env{status: 200}} ->
        Logger.info("Message send succesfully")

      error ->
        Logger.error("Failed to send message", error: error)
    end
  end

  def get_user_name(sender_id) do
    case get("/#{sender_id}", query: [access_token: access_token()]) do
      {:ok, %Tesla.Env{body: profile, status: 200}} ->
        Helpers.get_name_from_profile(profile)

      error ->
        # Returning "there" in case of error so that the message reads: "Hi there.!"
        Logger.error("Failed to get username", error: error)
        "there"
    end
  end

  defp access_token, do: System.get_env("FB_PAGE_ACCESS_TOKEN")
end
