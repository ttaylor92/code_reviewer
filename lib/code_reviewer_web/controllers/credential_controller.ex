defmodule CodeReviewerWeb.CredentialController do
  use CodeReviewerWeb, :controller
  alias CodeReviewer.SchemasPg.CredentialManagment

  def create(conn, params) do

    params
    |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)
    |> CredentialManagment.create()
    |> case do
      {:ok, _credential} ->
        conn
        |> put_status(:created)
        |> json(%{
          message: "Credential created successfully"
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Failed to create credential",
          details: format_changeset_errors(changeset)
        })
    end
  end

  # Helper function to format changeset errors
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
