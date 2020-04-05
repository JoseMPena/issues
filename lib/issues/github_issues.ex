defmodule Issues.GithubIssues do
  @user_agent [{"User-agent", "Elixir jose@botcity.co"}]
  # use a module attribute to fetch the value at compile time 
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  def handle_response({_, %{status_code: status_code, body: body}}) do
    status = status_code |> check_for_error()

    {
      status,
      decode_response({status, Poison.Parser.parse!(nil, body)})
    }
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
    IO.puts("Error fetching from Github: #{error["message"]}")
    System.halt(2)
  end

  defp check_for_error(200), do: :ok
  defp check_for_error(_), do: :error
end
