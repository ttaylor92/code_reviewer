# Start ExUnit
ExUnit.start()

# Start the sandbox
Ecto.Adapters.SQL.Sandbox.mode(CodeReviewer.Repo, :manual)

# Load all test support files
Code.require_file("test/support/mocks.ex")
Code.require_file("test/support/data_case.ex")
Code.require_file("test/support/mock_helper.ex")
