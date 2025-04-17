defmodule CodeReviewerWeb.WebhookController do
  use CodeReviewerWeb, :controller
  alias CodeReviewer.GithubActions

  @valid_actions [
    "assigned",
    "auto_merge_disabled",
    "auto_merge_enabled",
    "closed",
    "converted_to_draft",
    "demilestoned",
    "dequeued",
    "edited",
    "enqueued",
    "labeled",
    "locked",
    "milestoned",
    "review_request_removed",
    "unassigned",
    "unlabeled",
    "unlocked",
    "opened",
    "ready_for_review",
    "reopened",
    "review_requested",
    "synchronize"
  ]

  def handle(conn, params) do
    with {:ok, _event_type} <- get_event_type(conn),
         {:ok, action} <- validate_action(params) do
      case action do
        ev when ev in ["opened", "reopened", "ready_for_review"] ->
          handle_pull_request(conn, params, action)

        _ ->
          conn
          |> put_status(:ok)
          |> json(%{message: "Recieved but event type not supported"})
      end
    else
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  defp get_event_type(conn) do
    case get_req_header(conn, "x-github-event") do
      ["pull_request"] -> {:ok, "pull_request"}
      _ -> {:error, "Missing or invalid GitHub event type header"}
    end
  end

  defp validate_action(%{"action" => action}) when action in @valid_actions do
    {:ok, action}
  end

  defp validate_action(%{"action" => _}) do
    {:error, "Invalid action type"}
  end

  defp validate_action(_) do
    {:error, "Missing action parameter"}
  end

  defp handle_pull_request(conn, params, action) when action in @valid_actions do
    # Process the pull request with our GithubActions module
    GithubActions.process_pull_request(params)

    # Respond to keep connections clear
    conn
    |> put_status(:ok)
    |> json(%{message: "Pull request processed successfully"})
  end

  defp handle_pull_request(conn, _params, _action) do
    conn
    |> put_status(:ok)
    |> json(%{message: "Action type does not require processing"})
  end
end
