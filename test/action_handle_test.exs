defmodule StudyTcpServer.ActionHandleTest do
  use ExUnit.Case, async: true
  alias StudyTcpServer.ActionHandle
  alias StudyTcpServer.Request

  doctest StudyTcpServer.ActionHandle

  @http_version "HTTP/1.1"

  test "/now" do
    {status_code, response_body, content_type} =
      ActionHandle.dispatch(%Request{
        method: "GET",
        path: "/now",
        http_version: @http_version
        })
    assert status_code == 200
    assert String.match?(response_body, ~r/<h1>Now:/)
    assert content_type == "text/html; charset=UTF-8"
  end

  test "/show_request" do
    {status_code, response_body, content_type} =
      ActionHandle.dispatch(%Request{
        method: "GET",
        path: "/show_request",
        http_version: @http_version,
        headers: ["Host: localhost:8080"],
        body: "body=sample"
        })
    assert status_code == 200
    assert String.match?(response_body, ~r/GET \/show_request HTTP\/1.1/)
    assert String.match?(response_body, ~r/<pre>Host: localhost:8080<\/pre>/)
    assert String.match?(response_body, ~r/<pre>body=sample<\/pre>/)
    assert content_type == "text/html; charset=UTF-8"
  end

  test "GET /parameters" do
    {status_code, response_body, content_type} =
      ActionHandle.dispatch(%Request{
        method: "GET",
        path: "/parameters",
        http_version: @http_version,
        })

    assert status_code == 405
    assert String.match?(response_body, ~r/<h1>405 Method Not Allowed<\/h1>/)
    assert content_type == "text/html; charset=UTF-8"
  end

  test "POST /parameters" do
    {status_code, response_body, content_type} =
      ActionHandle.dispatch(%Request{
        method: "POST",
        path: "/parameters",
        http_version: @http_version,
        body: "body=sample"
        })

    assert status_code == 200
    assert String.match?(response_body, ~r/<pre>body: sample\r\n<\/pre>/)
    assert content_type == "text/html; charset=UTF-8"
  end
end
