defmodule StudyTcpServer.Response do

  def build(status_code, response_body, content_type) do
    {:ok, now} = DateTime.now("Etc/UTC")

    response_header = build_response_header(now, content_type, byte_size(response_body))
    response_line = build_response_line(status_code)
    response_line <> "\r\n" <> response_header <> "\r\n" <> response_body
  end

  defp build_response_header(now, content_type, content_length) do
    response_header = ""
    response_header = response_header <> "Date: #{Calendar.strftime(now, "%a, %d %b %Y %H:%M:%S GMT")}"
    response_header = response_header <> "Host: HenaServer/0.1\r\n"
    response_header = response_header <> "Content-Length: #{content_length}\r\n"
    response_header = response_header <> "Connection: Close\r\n"
    response_header <> "Content-Type: #{content_type}\r\n"
  end

  defp build_response_line(status_code) when status_code == 200, do: "HTTP/1.1 200 OK"
  defp build_response_line(status_code) when status_code == 404, do: "HTTP/1.1 404 Not Found"
  defp build_response_line(status_code) when status_code == 405, do: "HTTP/1.1 405 Method Not Allowed"

end
