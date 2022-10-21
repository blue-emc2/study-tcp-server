defmodule StudyTcpServer.ResponseTest do
  use ExUnit.Case, async: true

  test "#build" do
    response =
      StudyTcpServer.Response.build(200, "<!DOCTYPE html>", "text/html")

    assert String.match?(response, ~r/HTTP\/1.1 200 OK/)
    assert String.match?(response, ~r/Host: HenaServer\/0.1/)
    assert String.match?(response, ~r/Content-Length: 15/)
    assert String.match?(response, ~r/Content-Type: text\/html/)
    assert String.match?(response, ~r/<!DOCTYPE html>/)
    assert String.match?(response, ~r/text\/html/)
  end
end
