defmodule StudyTcpServer.Request do
  defstruct line: "", headers: [], body: ""
  require Logger

  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

      iex> StudyTcpServer.Request.parse("GET / HTTP/1.1\r\nHost: localhost:8080\r\n\r\nbody=sample")
      %StudyTcpServer.Request{
        line: "GET / HTTP/1.1",
        headers: ["Host: localhost:8080"],
        body: "body=sample"
      }

  """

  def parse(request) do
    [request_line, headers_and_body] = String.split(request, "\r\n", parts: 2)
    [headers, body] =
      if String.match?(headers_and_body, ~r{\r\n\r\n}) do
        String.split(headers_and_body, "\r\n\r\n", parts: 2)
      else
        [headers_and_body, ""]
      end

    %StudyTcpServer.Request{
      line: request_line,
      headers: [headers],
      body: body
    }
  end
end
