defmodule TCPClient do
  require Logger

  def request do
    Logger.info("=== サーバーと接続します ===")

    {:ok, client} = :gen_tcp.connect('127.0.0.1', 80, [active: false, packet: 0])

    Logger.info("=== サーバーとの接続が完了しました ===")

    # client_send.txtの最後の空行はbody部なので消さない
    {:ok, request} = File.read("client_send.txt")

    case :gen_tcp.send(client, request) do
      :ok -> Logger.info("=== 送信成功です ===")
      {:error, reason} -> Logger.error(inspect(reason))
    end

    case :gen_tcp.recv(client, 0) do
      {:ok, data} ->
        Logger.info("=== 受信しました ===")
        Logger.info(data)
        {:ok, file} = File.open("client_recv.txt", [:append])
        IO.binwrite(file, data)
        File.close(file)

      {:error, reason} ->
        Logger.error(inspect(reason))
    end

    :gen_tcp.close(client)

    Logger.info("=== 終了しました ===")
  end
end
