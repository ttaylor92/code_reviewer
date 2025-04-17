defmodule CodeReviewer.SchemasPg.CredentialManagment.Credential do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
    github_api_token: binary() | nil,
    ai_api_token: binary() | nil,
    # inserted_at: DateTime.t() | nil,
    # updated_at: DateTime.t() | nil
  }

  schema "credentials" do
    field :github_api_token, :string
    field :ai_api_token, :string

  end

  @required_fields [
    :github_api_token,
    :ai_api_token
  ]
  @allowed_fields [] ++ @required_fields

  def changeset(model_or_changeset, attrs \\ %{}) do
    model_or_changeset
    |> cast(attrs, @allowed_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:github_api_token)
    |> unique_constraint(:ai_api_token)
  end

  @doc false
  @spec create_changeset(attrs :: map()) :: Ecto.Changeset.t()
  def create_changeset(attrs \\ %{}) do
    changeset(%__MODULE__{}, attrs)
  end
end
