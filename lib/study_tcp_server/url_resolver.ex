defmodule StudyTcpServer.UrlResolver do

  def resolve(request) do
    # ここら辺を汎用的にするとフレームワークっぽくなるんだろうか
    {:ok , regex} = Regex.compile("/user/(?<user_id>(.+?))/profile")

    if Regex.match?(regex, request.path) do
      path_params = Regex.named_captures(regex, request.path)
      %{request | path: "/user/<user_id>/profile", params: %{user_id: path_params["user_id"]} }
    else
      request
    end
  end
end
