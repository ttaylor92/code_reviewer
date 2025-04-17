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
    replace_string_in_lines(lines, "--- a/")
  end

  defp parse_file_new(lines) do
    replace_string_in_lines(lines, "+++ b/")
  end

  defp replace_string_in_lines(lines, string) do
    lines
    |> Enum.find(&String.starts_with?(&1, string))
    |> then(fn
      nil -> ""
      v -> String.replace_prefix(v, string, "")
    end)
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
