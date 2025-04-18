defmodule CodeReviewer.MockHelper do
  @moduledoc """
  Helper module for setting up mocks in tests.
  """

  defmacro __using__(_opts) do
    quote do
      import Mox
      import ExUnit.Callbacks

      # Make sure mocks are verified when the test exits
      setup :verify_on_exit!

      # Helper function to set up default mock responses
      def setup_mocks do
        # Setup AIClient mock
        Mox.defmock(CodeReviewer.AIClientMock, for: CodeReviewer.AIClient.Behaviour)
        Application.put_env(:code_reviewer, :ai_client, CodeReviewer.AIClientMock)

        # Setup GitHubClient mock
        Mox.defmock(CodeReviewer.GitHubClientMock, for: CodeReviewer.GitHubActions.Behaviour)
        Application.put_env(:code_reviewer, :github_client, CodeReviewer.GitHubClientMock)

        # Setup CredentialManagment mock
        Mox.defmock(CodeReviewer.SchemasPg.CredentialManagmentMock, for: CodeReviewer.SchemasPg.CredentialManagment.Behaviour)
        Application.put_env(:code_reviewer, :credential_managment, CodeReviewer.SchemasPg.CredentialManagmentMock)

        # Setup default mock responses
        setup_default_mock_responses()
      end

      defp setup_default_mock_responses do
        # Default AIClient mock responses
        Mox.stub(CodeReviewer.AIClientMock, :analyze_code, fn _diff, _rules ->
          {:ok, "Mock AI analysis"}
        end)

        # Default GitHubClient mock responses
        Mox.stub(CodeReviewer.GitHubClientMock, :get_diff, fn _owner, _repo, _pr_number ->
          {:ok, %{body: "mock diff", parsed_body: %{file_new: "test.ex"}}}
        end)

        Mox.stub(CodeReviewer.GitHubClientMock, :get_pull_request, fn _owner, _repo, _pr_number ->
          {:ok, %{"title" => "Test PR", "body" => "Test body"}}
        end)

        Mox.stub(CodeReviewer.GitHubClientMock, :post_comment, fn _owner, _repo, _pr_number, _comment ->
          {:ok, %{status: 201}}
        end)

        Mox.stub(CodeReviewer.GitHubClientMock, :update_pr_status, fn _owner, _repo, _pr_number, _status, _description ->
          {:ok, %{status: 200}}
        end)

        # Default CredentialManagment mock responses
        Mox.stub(CodeReviewer.SchemasPg.CredentialManagmentMock, :find, fn ->
          {:ok, %{github_api_token: "mock-token", ai_api_token: "mock-token"}}
        end)

        Mox.stub(CodeReviewer.SchemasPg.CredentialManagmentMock, :create, fn _attrs ->
          {:ok, %{github_api_token: "mock-token", ai_api_token: "mock-token"}}
        end)
      end
    end
  end
end
