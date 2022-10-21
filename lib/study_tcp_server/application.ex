defmodule StudyTcpServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias StudyTcpServer.Server.WebServer

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: StudyTcpServer.Worker.start_link(arg)
      {Task.Supervisor, name: WebServer.TaskSupervisor},
      {Task, fn -> WebServer.run end}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WebServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
