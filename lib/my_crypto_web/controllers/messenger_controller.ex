defmodule MyCryptoWeb.MessengerController do
  use MyCryptoWeb, :controller

  alias MyCrypto.Messenger

  def validate(conn, %{
        "hub.mode" => "subscribe",
        "hub.challenge" => challenge,
        "hub.verify_token" => verify_token
      }) do
    case Messenger.validate_verify_token(verify_token) do
      true ->
        conn
        |> put_resp_content_type("application/json")
        |> resp(200, challenge)
        |> send_resp

      false ->
        render(conn, "error.json")
    end
  end

  def validate(conn, _), do: render(conn, "error.json")

  def recieve_message(conn, params) do
    Messenger.read_message(params)
    render(conn, "success.json")
  end
end
