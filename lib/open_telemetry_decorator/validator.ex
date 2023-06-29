defmodule OpenTelemetryDecorator.Validator do
  @moduledoc false

  def validate_name(span_name) do
    if not (is_binary(span_name) and span_name != "") do
      raise(ArgumentError, "span_name: `#{inspect(span_name)}` must be a non-empty string")
    end
  end

  def validate_paths(attr_keys, path_name) do
    if not (is_list(attr_keys) and singular_atom_or_list_starts_with_atom?(attr_keys)) do
      raise(
        ArgumentError,
        "The `#{path_name}` option must be a list of paths, " <>
          "each starting with an atom naming a variable at the root scope of the traced function: (atom | [atom | list])"
      )
    end
  end

  defp singular_atom_or_list_starts_with_atom?(list) do
    Enum.all?(list, fn
      item when is_atom(item) -> true
      [item | _rest] when is_atom(item) -> true
      _ -> false
    end)
  end
end
