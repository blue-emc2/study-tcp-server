defmodule TCPServer do
  require Logger

  def serv do
    Logger.info("=== サーバーを起動します ===")
    {:ok, socket} = :gen_tcp.listen(8080, [:binary, packet: 0, active: false, reuseaddr: true])

    Logger.info("=== クライアントからの接続を待ちます ===")
    {:ok, client} = :gen_tcp.accept(socket)

    Logger.info("=== 受信しました ===")
    case :gen_tcp.recv(client, 0) do
      {:ok, data} ->
        Logger.info(data)
        {:ok, file} = File.open("server_recv.txt", [:write])
        IO.binwrite(file, data)
        File.close(file)

        {:ok, response} = File.read("server_send.txt")

        case :gen_tcp.send(client, response) do
          :ok -> Logger.info("=== 送信成功です ===")
          {:error, reason} -> Logger.error(inspect(reason))
        end

        :gen_tcp.close(client)

      {:error, reason} ->
        Logger.error(inspect(reason))
    end

    :gen_tcp.close(socket)
  end

end
