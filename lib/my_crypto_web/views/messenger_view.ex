defmodule MyCryptoWeb.MessengerView do
  use MyCryptoWeb, :view

  def render("success.json", _), do: %{status: :ok}

  def render("error.json", _) do
    %{status: "error", message: "invalid payload"}
  end
end
