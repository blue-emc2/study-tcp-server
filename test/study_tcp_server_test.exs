defmodule StudyTcpServerTest do
  use ExUnit.Case
  doctest StudyTcpServer

  test "greets the world" do
    assert StudyTcpServer.hello() == :world
  end
end
