defmodule CodeReviewer.GitHubActions do
  @moduledoc """
  Module for interacting with GitHub API.
  """

  alias CodeReviewer.AIClient
  use Tesla, only: [:get, :post]

  plug Tesla.Middleware.BaseUrl, "https://api.github.com"
  plug Tesla.Middleware.JSON

  defp get_client(username) do
    case client() do
      __MODULE__ ->
        with {:ok, %{github_api_token: github_api_token}} <-
               credential_managment().find() do
          Tesla.client([
            {Tesla.Middleware.Headers,
             [
               {"Authorization", "Bearer #{github_api_token || System.get_env("GITHUB_TOKEN")}"},
               {"X-GitHub-Api-Version", "2022-11-28"},
               {"Accept", "application/vnd.github.v3.diff"},
               {"User-Agent", username}
             ]}
          ])
        end
      mock_client ->
        mock_client
    end
  end

  def process_pull_request(payload) do
    # Extract pull request information
    pr_number = payload["number"]
    repo = payload["repository"]["name"]
    owner = payload["sender"]["login"]
    sha = payload["pull_request"]["head"]["sha"]

    with {:ok, diff} <- get_diff(owner, repo, pr_number),
         {:ok, rules} <- get_custom_rules(),
         {:ok, analysis} <- AIClient.analyze_code(diff, rules) do
      # Create annotations
      create_annotations(repo, pr_number, analysis, owner, sha, diff[:parsed_body])
    end
  end

  def get_diff(owner, repo, pr_number) do
    case client() do
      __MODULE__ ->
        with {:ok, client} <- get_client(owner),
             {:ok, %{status: 200, body: body}} <-
               get(client, "/repos/#{owner}/#{repo}/pulls/#{pr_number}") do
          # Format the diff for the AI
          parsed_body = CodeReviewer.DiffParser.parse(body)
          {:ok, %{body: body, parsed_body: parsed_body}}
        end
      mock_client ->
        mock_client.get_diff(owner, repo, pr_number)
    end
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

  defp create_annotations(repo, pr_number, analysis, owner, sha, parsed_body) do
    IO.puts("Processing Annotations")
    with {:ok, %{github_api_token: github_api_token}} <-
           credential_managment().find() do
      # Parse the AI's analysis to extract violations
      violations = parse_analysis(analysis)

      client =
        Tesla.client([
          {Tesla.Middleware.Headers,
           [
             {"Authorization", "Bearer #{github_api_token || System.get_env("GITHUB_TOKEN")}"},
             {"Accept", "application/vnd.github-commitcomment.raw+json"},
             {"User-Agent", owner}
           ]}
        ])

      for v <- violations do
        with {:ok, %{status: 201}} <-
               post(client, "repos/#{owner}/#{repo}/pulls/#{pr_number}/comments", %{
                 body: v.message,
                 commit_id: sha,
                 path: parsed_body.file_new,
                 start_line: v.start_line,
                 line: v.start_line + 1,
                 side: "RIGHT",
                 start_side: "RIGHT"
               }) do
          IO.puts("Annotation has been added")
          :ok
        end
      end
    end
  end

  defp parse_analysis(analysis) do
    # Split the analysis into individual violations
    violations =
      analysis
      |> String.split(~r/\n\n\d+\.\s/)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(fn violation ->
        # Extract components using regex
        file_path =
          case Regex.run(~r/File: `([^`]+)`/, violation) do
            [_, path] -> path
            _ -> "unknown_file"
          end

        line_numbers =
          case Regex.run(~r/Lines? (\d+(?:-\d+)?(?:,\s*\d+(?:-\d+)?)*)/i, violation) do
            [_, lines] ->
              lines
              |> String.split(",", trim: true)
              |> Enum.flat_map(fn range ->
                case String.split(String.trim(range), "-") do
                  [single] ->
                    [String.to_integer(single)]

                  [start, end_line] ->
                    start_num = String.to_integer(start)
                    end_num = String.to_integer(end_line)
                    Enum.to_list(start_num..end_num)
                end
              end)

            _ ->
              [1]
          end

        rule_file =
          case Regex.run(~r/Rule file: ([^\n]+)/, violation) do
            [_, file] -> file
            _ -> "Unknown Rule"
          end

        explanation =
          case Regex.run(~r/Explanation: ([^\n]+)/, violation) do
            [_, exp] -> exp
            _ -> "No explanation provided"
          end

        suggested_fix =
          case Regex.run(~r/Suggested fix: ([^\n]+)/, violation) do
            [_, fix] -> fix
            _ -> "No fix suggested"
          end

        # Create an annotation for each line number
        Enum.map(line_numbers, fn line_number ->
          %{
            path: file_path,
            start_line: line_number,
            end_line: line_number,
            annotation_level: "warning",
            message: """
            Rule violated: #{rule_file}
            #{explanation}

            Suggested fix: #{suggested_fix}
            """,
            title: "Code Review Violation"
          }
        end)
      end)
      # Flatten the list of lists into a single list of annotations
      |> List.flatten()

    violations
  end

  defp parse_git_diff(diff_string) do
    # Split the diff into sections by "diff --git" marker
    diff_sections =
      String.split(diff_string, "diff --git")
      # Remove empty strings
      |> Enum.reject(&(&1 == ""))

    Enum.map_join(diff_sections, "\n\n", fn section ->
      # Extract filename from the diff header
      filename =
        case Regex.run(~r{(?:a/|b/)([^\s]+)}, section) do
          [_, name] -> name
          _ -> "unknown_file"
        end

      # Extract the actual changes (lines starting with + or -)
      changes =
        String.split(section, "\n")
        |> Enum.filter(fn line ->
          String.starts_with?(line, "+") || String.starts_with?(line, "-")
        end)
        |> Enum.reject(fn line ->
          # Filter out diff metadata lines that start with +++ or ---
          String.starts_with?(line, "+++") || String.starts_with?(line, "---")
        end)
        |> Enum.join("\n")

      """
      File: #{filename}
      #{changes}
      """
    end)
  end

  def get_pull_request(owner, repo, pr_number) do
    client().get_pull_request(owner, repo, pr_number)
  end

  def post_comment(owner, repo, pr_number, comment) do
    client().post_comment(owner, repo, pr_number, comment)
  end

  def update_pr_status(owner, repo, pr_number, status, description) do
    client().update_pr_status(owner, repo, pr_number, status, description)
  end

  defp client do
    Application.get_env(:code_reviewer, :github_client, __MODULE__)
  end

  defp credential_managment do
    Application.get_env(:code_reviewer, :credential_managment, CodeReviewer.SchemasPg.CredentialManagment)
  end
end
