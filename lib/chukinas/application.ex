defmodule Chukinas.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  alias Chukinas.Sessions.SessionSupervisor
  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ChukinasWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Chukinas.PubSub},
      # Start the Endpoint (http/https)
      ChukinasWeb.Endpoint,
      {SessionSupervisor, []},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chukinas.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ChukinasWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
