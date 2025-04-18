defmodule CodeReviewer.SchemasPg.CredentialManagment.Behaviour do
  @moduledoc """
  Behaviour for credential management implementations.
  """

  @callback find() :: {:ok, map()} | {:error, String.t()}
  @callback create(map()) :: {:ok, map()} | {:error, map()}
end
