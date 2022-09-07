defmodule MyCrypto.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Create an ETS table
    :ets.new(:sender_state, [:set, :public, :named_table])

    children = [
      # Start the Telemetry supervisor
      MyCryptoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MyCrypto.PubSub},
      # Start the Endpoint (http/https)
      MyCryptoWeb.Endpoint
      # Start a worker by calling: MyCrypto.Worker.start_link(arg)
      # {MyCrypto.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MyCrypto.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MyCryptoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
