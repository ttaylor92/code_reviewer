defmodule CodeReviewer.AIClient do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.aimlapi.com/v1"
  plug Tesla.Middleware.JSON

  @client Tesla.client([
    {Tesla.Middleware.Headers,
     [
       {"Authorization", "Bearer #{System.get_env("AIML_API_KEY")}"},
     ]}
  ])

  def analyze_code(code, rules) do
    system_prompt = """
    You are an expert code reviewer. Analyze the following code against these rules and identify any violations.
    For each violation, provide:
    1. The specific line(s) of code that violate the rule
    2. A clear explanation of the violation
    3. A suggested fix
    4. The name of the rule file that was violated

    Rules:
    #{rules}
    """

    user_prompt = """
    Please review this code:
    #{code[:body]}
    """

    with {:ok, %_{status: 201, body: body}} <- post(@client, "/chat/completions", %{
      model: "mistralai/Mistral-7B-Instruct-v0.2",
      messages: [
        %{role: "system", content: system_prompt},
        %{role: "user", content: user_prompt}
      ],
      temperature: 0.7,
      max_tokens: 1000
    }) do
      content = List.first(body["choices"])["message"]["content"]
      {:ok, content}
    end
  end

  def generate_tests(code, context) do
    system_prompt = """
    You are an expert test writer for Elixir and Phoenix LiveView applications.
    Generate comprehensive test cases for the provided code.
    Include both unit tests and integration tests where appropriate.
    Use ExUnit for Elixir tests and Phoenix.LiveViewTest for LiveView tests.
    """

    user_prompt = """
    Please generate tests for this code:
    #{code}

    Context:
    #{context}
    """

    case Tesla.post(@client, "/chat/completions", %{
      model: "mistralai/Mistral-7B-Instruct-v0.2",
      messages: [
        %{role: "system", content: system_prompt},
        %{role: "user", content: user_prompt}
      ],
      temperature: 0.7,
      max_tokens: 1000
    }) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body["choices"][0]["message"]["content"]}
      {:error, error} ->
        {:error, error}
    end
  end
end
