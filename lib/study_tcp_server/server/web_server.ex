defmodule StudyTcpServer.Server.WebServer do
  require Logger
  alias StudyTcpServer.Server.WebServer

  def run do
    Logger.info("=== サーバーを起動します pid=#{inspect(self())} ===")
    {:ok, socket} = :gen_tcp.listen(8080, [:binary, packet: 0, active: false, reuseaddr: true])

    loop_acceptor(socket)

    :gen_tcp.close(socket)
  end

  defp loop_acceptor(socket) do
    Logger.info("=== クライアントからの接続を待ちます pid=#{inspect(self())} ===")
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(WebServer.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(client) do
    response =
      with {:ok, data} <- read_request(client),
        request <- StudyTcpServer.Request.parse(data),
        {status_code, response_body, content_type} <- StudyTcpServer.ActionHandle.dispatch(request),
        do: StudyTcpServer.Response.build(status_code, response_body, content_type)

    Logger.info(inspect(response))
    send_response(client, response)
  end

  defp read_request(client) do
    :gen_tcp.recv(client, 0)
  end

  defp send_response(client, response) do
    case :gen_tcp.send(client, response) do
      :ok -> Logger.info("=== 送信成功です pid=#{inspect(self())} ===")
      {:error, reason} -> Logger.error(inspect(reason))
    end
  end
end
