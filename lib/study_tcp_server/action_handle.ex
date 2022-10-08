defmodule StudyTcpServer.ActionHandle do
  alias StudyTcpServer.Request
  require Logger

  @doc """
  """

  @base_dir File.cwd!
  @static_root Path.join([@base_dir, "static"])
  @mime_types %{
    "html" => "text/html; charset=UTF-8",
    "css" => "text/css",
    "png" => "image/png",
    "jpg" => "image/jpg",
    "gif" => "image/gif",
  }

  def dispatch(%Request{} = request) do
    parse(request)
    |> run()
  end

  defp parse(request) do
    case [request.method, request.path, request.http_version] do
      ["GET", "/now", _http_version] -> {:get, :now}
      ["GET", "/show_request", http_version] -> {:get, :show_request, ["GET", "/show_request", http_version, request]}
      ["GET", "/parameters", _http_version] -> {:get, :parameters}
      ["GET", path, _http_version] -> {:get, path}
      ["POST", "/parameters", _http_version] -> {:post, :parameters, [request]}
    end
  end

  defp run({:get, :now}) do
    {:ok, datetime} = DateTime.now("Etc/UTC")
    response_body = """
    <html>
      <body>
        <h1>Now: #{datetime}</h1>
      </body>
    </html>
    """

    {200, response_body, "text/html; charset=UTF-8"}
  end

  defp run({:get, :show_request, [method, path, http_version, request]}) do
    headers = request.headers
    body = request.body

    response_body = """
    <html>
      <body>
        <h1>Request Line:</h1>
        <p>
            #{method} #{path} #{http_version}
        </p>
        <h1>Headers:</h1>
        <pre>#{headers}</pre>
        <h1>Body:</h1>
        <pre>#{body}</pre>
      </body>
    </html>
    """

    {200, response_body, "text/html; charset=UTF-8"}
  end

  defp run({:get, :parameters}) do
    response_body = "<html><body><h1>405 Method Not Allowed</h1></body></html>"
    content_type = "text/html; charset=UTF-8"

    {405, response_body, content_type}
  end

  defp run({:post, :parameters, [request]}) do
    body = request.body
    parameter_map =
      URI.decode(body)
      |> String.split("&")
      |> Enum.map(fn param -> String.split(param, "=") end)
      |> Enum.map(fn [k, v] -> "#{k}: #{v}\r\n" end)

    response_body = """
      <html>
      <body>
          <h1>Parameters:</h1>
          <pre>#{parameter_map}</pre>
      </body>
      </html>
    """
    content_type = "text/html; charset=UTF-8"

    {200, response_body, content_type}
  end

  defp run({:get, path}) do
    static_file_path = Path.join(@static_root, path)

    {status_code, response_body, content_type} =
      case File.read(static_file_path) do
        {:ok, response_body} ->
          ext = Path.extname(path) |> String.replace_prefix(".", "")
          content_type = Map.get(@mime_types, ext, "application/octet-stream")

          {200, response_body, content_type}
        {:error, _} ->
          {
            404,
            "<html><body><h1>404 Not Found</h1></body></html>",
            Map.get(@mime_types, "html")
          }
      end

    {status_code, response_body, content_type}
  end
end
