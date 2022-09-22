defmodule WebServer do
  require Logger

  @base_dir File.cwd!
  @static_root Path.join([@base_dir, "static"])
  @mime_types %{
    "html" => "text/html",
    "css" => "text/css",
    "png" => "image/png",
    "jpg" => "image/jpg",
    "gif" => "image/gif",
  }

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
    case :gen_tcp.recv(client, 0) do
      {:ok, request} ->
        Logger.info("=== 受信しました pid=#{inspect(self())} ===")
        {:ok, file} = File.open("sample/server_recv.txt", [:write])
        IO.binwrite(file, request)
        File.close(file)

        response = build_response(request)

        case :gen_tcp.send(client, response) do
          :ok -> Logger.info("=== 送信成功です pid=#{inspect(self())} ===")
          {:error, reason} -> Logger.error(inspect(reason))
        end

        :gen_tcp.close(client)

      {:error, reason} ->
        Logger.error(inspect(reason))
        :gen_tcp.close(client)
    end
  end

  defp parse_request(request) do
    {[request_line], [remain]} = String.split(request, "\r\n", parts: 2) |> Enum.split(1)
    {request_header, request_body} = remain |> String.split("\r\n\r\n") |> Enum.split(1)

    {request_line, request_header, request_body}
  end

  defp build_response(request) do
    {request_line, request_header, request_body} = parse_request(request)
    [method, path, http_version] = request_line |> String.split(" ")
    {:ok, datetime} = DateTime.now("Etc/UTC")

    {response_line, response_body, content_type} =
      case path do
        "/now" ->
          response_body = """
          <html>
            <body>
              <h1>Now: #{datetime}</h1>
            </body>
          </html>
          """

          {"HTTP/1.1 200 OK\r\n", response_body, "text/html"}

        "/show_request" ->
          response_body = """
          <html>
            <body>
              <h1>Request Line:</h1>
              <p>
                  #{method} #{path} #{http_version}
              </p>
              <h1>Headers:</h1>
              <pre>#{request_header}</pre>
              <h1>Body:</h1>
              <pre>#{request_body}</pre>
            </body>
          </html>
          """

          {"HTTP/1.1 200 OK\r\n", response_body, "text/html"}
        _ ->
          static_file_path = Path.join(@static_root, path)

          {response_line, response_body} =
            case File.read(static_file_path) do
              {:ok, response_body} -> {"HTTP/1.1 200 OK\r\n", response_body}
              {:error, _} ->
                {
                  "HTTP/1.1 404 Not Found\r\n",
                  "<html><body><h1>404 Not Found</h1></body></html>"
                }
            end

          ext = Path.extname(path) |> String.replace_prefix(".", "")
          content_type = Map.get(@mime_types, ext, "application/octet-stream")

          {response_line, response_body, content_type}
      end

    response_header = build_response_header(datetime, content_type, String.length(response_body))

    Logger.info(response_header)
    if content_type == "text/html" do
      Logger.info(response_body)
    end

    response_line <> response_header <> "\r\n" <> response_body
  end

  defp build_response_header(now, content_type, content_length) do
    response_header = ""
    response_header = response_header <> "Date: #{Calendar.strftime(now, "%a, %d %b %Y %H:%M:%S GMT")}"
    response_header = response_header <> "Host: HenaServer/0.1\r\n"
    response_header = response_header <> "Content-Length: #{content_length}\r\n"
    response_header = response_header <> "Connection: Close\r\n"
    response_header <> "Content-Type: #{content_type}\r\n"
  end
end
