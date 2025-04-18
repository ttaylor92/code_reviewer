defmodule CodeReviewer.AIClient.Behaviour do
  @moduledoc """
  Behaviour for AI client implementations.
  """

  @callback analyze_code(map(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  @callback generate_tests(String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
end
