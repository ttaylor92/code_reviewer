defmodule CodeReviewer.GithubActions do
  alias CodeReviewer.AIClient
  use Tesla, only: [:get, :post]

  plug Tesla.Middleware.BaseUrl, "https://api.github.com"
  plug Tesla.Middleware.JSON

  @client Tesla.client([
    {Tesla.Middleware.Headers,
     [
       {"Authorization", "Bearer #{System.get_env("GITHUB_TOKEN")}"},
       {"X-GitHub-Api-Version", "2022-11-28"},
       {"Accept", "application/vnd.github+json"}
     ]}
  ])

  def process_pull_request(payload) do
    # Extract pull request information
    pr_number = payload["number"]
    repo = payload["repository"]["name"]
    owner = payload["sender"]["login"]

    with {:ok, diff} <- get_diff(repo, pr_number, owner),
         {:ok, rules} <- get_custom_rules(),
         {:ok, analysis} <- AIClient.analyze_code(diff, rules) do
      # Create annotations
      create_annotations(repo, pr_number, analysis)
    end
  end

  defp get_diff(repo, pr_number, owner) do
    with {:ok, %{status: 200, body: body}} <-
           Tesla.get(@client, "/repos/#{owner}/#{repo}/pulls/#{pr_number}") do
      # Format the diff for the AI
      diff =
        Enum.map_join(body["files"], "\n\n", fn file ->
          """
          File: #{file["filename"]}
          #{file["patch"]}
          """
        end)

        IO.inspect(diff)

      {:ok, diff}
    end |> IO.inspect()
  end

  defp get_custom_rules do
    with {:ok, files} <- File.ls(".ai-code-rules") do
      rules =
        files
        |> Enum.filter(&String.ends_with?(&1, ".md"))
        |> Enum.map(fn file ->
          case File.read(".ai-code-rules/#{file}") do
            {:ok, content} -> content
            {:error, _} -> ""
          end
        end)
        |> Enum.join("\n\n")

      {:ok, rules}
    end
  end

  defp create_annotations(repo, _pr_number, analysis) do
    IO.inspect(analysis)
    # Parse the AI's analysis to extract violations
    violations = parse_analysis(analysis)

    # Create a check run
    case Tesla.post(@client, "/repos/#{repo}/check-runs", %{
           name: "AI Code Review",
           head_sha: System.get_env("GITHUB_SHA"),
           status: "completed",
           conclusion: "neutral",
           output: %{
             title: "AI Code Review Results",
             summary: "Code review completed by AI",
             annotations: violations
           }
         }) do
      {:ok, %{status: 201}} -> :ok
      {:error, error} -> {:error, error}
    end
  end

  defp parse_analysis(analysis) do
    # Split the analysis into individual violations
    violations =
      String.split(analysis, ~r/\n\n(?=\d+\.)/)
      |> Enum.filter(&String.starts_with?(&1, ~r/^\d+\./))

    # Convert each violation into a GitHub annotation
    Enum.map(violations, fn violation ->
      # Extract line number from the violation text
      line_number =
        Regex.run(~r/line (\d+)/, violation)
        |> case do
          [_, number] -> String.to_integer(number)
          _ -> 1
        end

      %{
        # This should be extracted from the violation
        path: "file.ex",
        start_line: line_number,
        end_line: line_number,
        annotation_level: "warning",
        message: violation,
        title: "Code Review Violation"
      }
    end)
  end
end
