defmodule CodeReviewer.AIClientTest do
  use CodeReviewer.DataCase
  use CodeReviewer.MockHelper

  alias CodeReviewer.AIClient
  alias CodeReviewer.AIClientMock

  describe "analyze_code/2" do
    test "successfully analyzes code and returns analysis" do
      setup_mocks()

      code = %{body: "defmodule Test do\n  def hello, do: :world\nend"}
      rules = "No global variables"

      expect(AIClientMock, :analyze_code, fn ^code, ^rules ->
        {:ok, "Analysis complete"}
      end)

      assert {:ok, "Analysis complete"} = AIClient.analyze_code(code, rules)
    end

    test "handles API errors gracefully" do
      setup_mocks()

      code = %{body: "defmodule Test do\n  def hello, do: :world\nend"}
      rules = "No global variables"

      expect(AIClientMock, :analyze_code, fn ^code, ^rules ->
        {:error, "API Error"}
      end)

      assert {:error, "API Error"} = AIClient.analyze_code(code, rules)
    end

    test "handles empty code input" do
      setup_mocks()

      code = %{body: ""}
      rules = "No global variables"

      expect(AIClientMock, :analyze_code, fn ^code, ^rules ->
        {:error, "Empty code provided"}
      end)

      assert {:error, "Empty code provided"} = AIClient.analyze_code(code, rules)
    end

    test "handles invalid code format" do
      setup_mocks()

      code = "invalid code format"
      rules = "No global variables"

      expect(AIClientMock, :analyze_code, fn ^code, ^rules ->
        {:error, "Invalid code format"}
      end)

      assert {:error, "Invalid code format"} = AIClient.analyze_code(code, rules)
    end

    test "handles rate limiting" do
      setup_mocks()

      code = %{body: "defmodule Test do\n  def hello, do: :world\nend"}
      rules = "No global variables"

      expect(AIClientMock, :analyze_code, fn ^code, ^rules ->
        {:error, "Rate limit exceeded"}
      end)

      assert {:error, "Rate limit exceeded"} = AIClient.analyze_code(code, rules)
    end
  end

  describe "generate_tests/2" do
    test "successfully generates tests" do
      setup_mocks()

      code = "defmodule Test do\n  def hello, do: :world\nend"
      context = "This is a test module"

      expect(AIClientMock, :generate_tests, fn ^code, ^context ->
        {:ok, "Generated test cases"}
      end)

      assert {:ok, "Generated test cases"} = AIClient.generate_tests(code, context)
    end

    test "handles API errors when generating tests" do
      setup_mocks()

      code = "defmodule Test do\n  def hello, do: :world\nend"
      context = "This is a test module"

      expect(AIClientMock, :generate_tests, fn ^code, ^context ->
        {:error, "API Error"}
      end)

      assert {:error, "API Error"} = AIClient.generate_tests(code, context)
    end

    test "handles empty code input" do
      setup_mocks()

      code = ""
      context = "This is a test module"

      expect(AIClientMock, :generate_tests, fn ^code, ^context ->
        {:error, "Empty code provided"}
      end)

      assert {:error, "Empty code provided"} = AIClient.generate_tests(code, context)
    end

    test "handles invalid code format" do
      setup_mocks()

      code = "invalid code format"
      context = "This is a test module"

      expect(AIClientMock, :generate_tests, fn ^code, ^context ->
        {:error, "Invalid code format"}
      end)

      assert {:error, "Invalid code format"} = AIClient.generate_tests(code, context)
    end

    test "handles rate limiting" do
      setup_mocks()

      code = "defmodule Test do\n  def hello, do: :world\nend"
      context = "This is a test module"

      expect(AIClientMock, :generate_tests, fn ^code, ^context ->
        {:error, "Rate limit exceeded"}
      end)

      assert {:error, "Rate limit exceeded"} = AIClient.generate_tests(code, context)
    end
  end
end
