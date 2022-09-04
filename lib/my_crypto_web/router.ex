defmodule MyCryptoWeb.Router do
  use MyCryptoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MyCryptoWeb do
    pipe_through :api
  end
end
