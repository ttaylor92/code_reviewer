defmodule CodeReviewer.Integration.ReviewFlowTest do
  use CodeReviewer.DataCase
  use CodeReviewer.MockHelper

  alias CodeReviewer.AIClient
  alias CodeReviewer.GitHubActions
  alias CodeReviewer.AIClientMock
  alias CodeReviewer.GitHubClientMock

  describe "complete review flow" do
    test "successfully reviews a pull request" do
      setup_mocks()

      owner = "test-owner"
      repo = "test-repo"
      pr_number = 123
      diff = "diff --git a/test.ex b/test.ex\n@@ -1,2 +1,2 @@\n-def hello, do: :world\n+def hello, do: :universe"
      rules = "No global variables"

      # Mock GitHub API calls
      expect(GitHubClientMock, :get_pull_request, fn ^owner, ^repo, ^pr_number ->
        {:ok, %{
          title: "Test PR",
          body: "Test body",
          files: [
            %{filename: "test.ex", status: "modified"}
          ]
        }}
      end)

      expect(GitHubClientMock, :get_diff, fn ^owner, ^repo, ^pr_number ->
        {:ok, diff}
      end)

      # Mock AI API calls
      expect(AIClientMock, :analyze_code, fn code, ^rules ->
        assert code[:body] == diff
        {:ok, "Code analysis complete"}
      end)

      # Mock GitHub comment posting
      expect(GitHubClientMock, :post_comment, fn ^owner, ^repo, ^pr_number, comment ->
        assert String.contains?(comment, "Code analysis complete")
        {:ok, %{id: 456}}
      end)

      # Mock status update
      expect(GitHubClientMock, :update_pr_status, fn ^owner, ^repo, ^pr_number, status, description ->
        assert status == "success"
        assert String.contains?(description, "Review completed")
        {:ok, %{state: status, description: description}}
      end)

      # Execute the review flow
      assert {:ok, _} = GitHubActions.get_pull_request(owner, repo, pr_number)
      assert {:ok, ^diff} = GitHubActions.get_diff(owner, repo, pr_number)
      assert {:ok, "Code analysis complete"} = AIClient.analyze_code(%{body: diff}, rules)
      assert {:ok, %{id: 456}} = GitHubActions.post_comment(owner, repo, pr_number, "Code analysis complete")
      assert {:ok, %{state: "success"}} = GitHubActions.update_pr_status(owner, repo, pr_number, "success", "Review completed")
    end

    test "handles errors during review flow" do
      setup_mocks()

      owner = "test-owner"
      repo = "test-repo"
      pr_number = 123

      # Mock GitHub API failure
      expect(GitHubClientMock, :get_pull_request, fn ^owner, ^repo, ^pr_number ->
        {:error, "GitHub API Error"}
      end)

      # Execute the review flow
      assert {:error, "GitHub API Error"} = GitHubActions.get_pull_request(owner, repo, pr_number)
    end

    test "handles AI analysis failure" do
      setup_mocks()

      owner = "test-owner"
      repo = "test-repo"
      pr_number = 123
      diff = "diff --git a/test.ex b/test.ex\n@@ -1,2 +1,2 @@\n-def hello, do: :world\n+def hello, do: :universe"

      # Mock successful GitHub API calls
      expect(GitHubClientMock, :get_pull_request, fn ^owner, ^repo, ^pr_number ->
        {:ok, %{
          title: "Test PR",
          body: "Test body",
          files: [
            %{filename: "test.ex", status: "modified"}
          ]
        }}
      end)

      expect(GitHubClientMock, :get_diff, fn ^owner, ^repo, ^pr_number ->
        {:ok, diff}
      end)

      # Mock AI API failure
      expect(AIClientMock, :analyze_code, fn code, _rules ->
        assert code[:body] == diff
        {:error, "AI Service Unavailable"}
      end)

      # Mock status update for failure
      expect(GitHubClientMock, :update_pr_status, fn ^owner, ^repo, ^pr_number, status, description ->
        assert status == "failure"
        assert String.contains?(description, "AI Service Unavailable")
        {:ok, %{state: status, description: description}}
      end)

      # Execute the review flow
      assert {:ok, _} = GitHubActions.get_pull_request(owner, repo, pr_number)
      assert {:ok, ^diff} = GitHubActions.get_diff(owner, repo, pr_number)
      assert {:error, "AI Service Unavailable"} = AIClient.analyze_code(%{body: diff}, "rules")
      assert {:ok, %{state: "failure"}} = GitHubActions.update_pr_status(owner, repo, pr_number, "failure", "AI Service Unavailable")
    end
  end
end
