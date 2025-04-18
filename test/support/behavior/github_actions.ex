defmodule CodeReviewer.GitHubActions.Behaviour do
  @moduledoc """
  Behaviour for GitHub client implementations.
  """

  @callback get_pull_request(String.t(), String.t(), integer()) :: {:ok, map()} | {:error, String.t()}
  @callback post_comment(String.t(), String.t(), integer(), String.t()) :: {:ok, map()} | {:error, String.t()}
  @callback get_diff(String.t(), String.t(), integer()) :: {:ok, String.t()} | {:error, String.t()}
  @callback update_pr_status(String.t(), String.t(), integer(), String.t(), String.t()) :: {:ok, map()} | {:error, String.t()}
end
