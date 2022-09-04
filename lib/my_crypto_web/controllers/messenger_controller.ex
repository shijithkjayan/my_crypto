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
        handle_error(conn)
    end
  end

  def validate(conn, _), do: handle_error(conn)

  def recieve_message(conn, params) do
    Messenger.read_message(params)

    conn
    |> put_resp_content_type("application/json")
    |> resp(200, Jason.encode!(%{status: :ok}))
    |> send_resp
  end

  defp handle_error(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> resp(422, Jason.encode!(%{status: "error", message: "invalid payload"}))
    |> send_resp
  end
end
