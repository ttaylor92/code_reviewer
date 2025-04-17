defmodule CodeReviewer.DiffParser do
  def parse(diff) do
    lines = String.split(diff, "\n", trim: true)

    %{
      file_old: parse_file_old(lines),
      file_new: parse_file_new(lines),
      index: parse_index(lines),
      hunk: parse_hunk(lines),
      changes: parse_changes(lines)
    }
  end

  defp parse_file_old(lines) do
    lines
    |> Enum.find(&String.starts_with?(&1, "--- a/"))
    |> String.replace_prefix("--- a/", "")
  end

  defp parse_file_new(lines) do
    lines
    |> Enum.find(&String.starts_with?(&1, "+++ b/"))
    |> String.replace_prefix("+++ b/", "")
  end

  defp parse_index(lines) do
    Enum.find(lines, &String.starts_with?(&1, "index "))
  end

  defp parse_hunk(lines) do
    Enum.find(lines, &String.starts_with?(&1, "@@ "))
  end

  defp parse_changes(lines) do
    lines
    |> Enum.drop_while(&(not String.starts_with?(&1, "@@ ")))
    |> tl()
    |> Enum.map(fn
      <<"+" <> content>> ->
        %{type: :addition, content: content}

      <<"-" <> content>> ->
        %{type: :deletion, content: content}

      _ ->
        nil
        # %{type: :context, content: line}
    end)
    |> Enum.filter(fn v -> !is_nil(v) end)
  end
end
