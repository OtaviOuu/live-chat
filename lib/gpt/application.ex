defmodule Gpt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GptWeb.Telemetry,
      Gpt.Repo,
      {DNSCluster, query: Application.get_env(:gpt, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Gpt.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Gpt.Finch},
      # Start a worker by calling: Gpt.Worker.start_link(arg)
      # {Gpt.Worker, arg},
      # Start to serve requests, typically the last entry
      GptWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gpt.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GptWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
