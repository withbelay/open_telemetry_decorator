defmodule OpenTelemetryDecorator.ValidatorTest do
  use ExUnit.Case, async: true

  alias OpenTelemetryDecorator.Validator

  test "event name must be a non-empty string" do
    Validator.validate_name("name_space.event")

    Validator.validate_name("A Fancier Name")

    assert_raise ArgumentError, ~r/^span_name/, fn ->
      Validator.validate_name("")
    end

    assert_raise ArgumentError, ~r/^span_name/, fn ->
      Validator.validate_name(nil)
    end
  end

  test "path can be empty" do
    Validator.validate_paths([], "test_path")
  end

  test "first reference in path must be atom" do
    Validator.validate_paths([:variable], "test_path")
    Validator.validate_paths([:variable, [:key1, :key2]], "test_path")
    Validator.validate_paths([:variable, [:key1, "key2"]], "test_path")

    assert_raise ArgumentError, ~r/The `test_path` option must be a list of paths/, fn ->
      Validator.validate_paths(["variable"], "test_path")
    end

    assert_raise ArgumentError, ~r/The `test_path` option must be a list of paths/, fn ->
      Validator.validate_paths([["variable", :key]], "test_path")
    end
  end

  test "attrs_keys can contain nested lists of atoms" do
    Validator.validate_paths([:variable, [:obj, :key]], "test_path")
  end
end
