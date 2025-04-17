defmodule CodeReviewer.Repo.Migrations.AddCredentialsDb do
  use Ecto.Migration

  def change do
    create table(:credentials) do
      add :github_api_token, :text
      add :ai_api_token, :text
    end
  end
end
