defmodule CodeReviewer.GitHubActionsTest do
  use ExUnit.Case
  use CodeReviewer.MockHelper

  alias CodeReviewer.GitHubActions

  setup do
    setup_mocks()
    :ok
  end

  describe "get_diff/3" do
    test "returns diff for a pull request" do
      owner = "test-owner"
      repo = "test-repo"
      pr_number = 1

      assert {:ok, %{body: "mock diff", parsed_body: %{file_new: "test.ex"}}} =
               GitHubActions.get_diff(owner, repo, pr_number)
    end
  end

  describe "get_pull_request/3" do
    test "returns pull request details" do
      owner = "test-owner"
      repo = "test-repo"
      pr_number = 1

      assert {:ok, %{"title" => "Test PR", "body" => "Test body"}} =
               GitHubActions.get_pull_request(owner, repo, pr_number)
    end
  end

  describe "post_comment/4" do
    test "posts a comment to a pull request" do
      owner = "test-owner"
      repo = "test-repo"
      pr_number = 1
      comment = "Test comment"

      assert {:ok, %{status: 201}} =
               GitHubActions.post_comment(owner, repo, pr_number, comment)
    end
  end

  describe "update_pr_status/5" do
    test "updates pull request status" do
      owner = "test-owner"
      repo = "test-repo"
      pr_number = 1
      status = "success"
      description = "Status updated"

      assert {:ok, %{status: 200}} =
               GitHubActions.update_pr_status(owner, repo, pr_number, status, description)
    end
  end
end
