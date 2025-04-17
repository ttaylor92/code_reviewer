defmodule CodeReviewer.SchemasPg.CredentialManagment do
  alias CodeReviewer.SchemasPg.CredentialManagment.Credential

  def create(attr) do
    EctoShorts.Actions.find_and_upsert(Credential, attr, attr)
  end

  @spec find() :: {:ok, Credential.t()} | {:error, map()}
  def find do
    EctoShorts.Actions.find(Credential, %{id: 1})
  end
end
