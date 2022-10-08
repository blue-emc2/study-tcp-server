defmodule StudyTcpServer.Request do
  defstruct headers: [], body: "", path: "", method: "", http_version: "", params: %{}
  require Logger

  @doc ~S"""

  ## Examples

      iex> StudyTcpServer.Request.parse("GET / HTTP/1.1\r\nHost: localhost:8080\r\n\r\nbody=sample")
      %StudyTcpServer.Request{
        path: "/",
        method: "GET",
        http_version: "HTTP/1.1",
        headers: ["Host: localhost:8080"],
        body: "body=sample"
      }

  """

  def parse(request) do
    [request_line, headers_and_body] = String.split(request, "\r\n", parts: 2)
    [method, path, http_version] = String.split(request_line)
    [headers, body] =
      if String.match?(headers_and_body, ~r{\r\n\r\n}) do
        String.split(headers_and_body, "\r\n\r\n", parts: 2)
      else
        [headers_and_body, ""]
      end

    %StudyTcpServer.Request{
      path: path,
      method: method,
      http_version: http_version,
      headers: [headers],
      body: body
    }
  end
end
