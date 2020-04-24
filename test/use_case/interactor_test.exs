defmodule UseCase.InteractorTest do
  use ExUnit.Case, async: true

  defmodule FakeUC do
    @moduledoc """
      My use case
    """
    use UseCase.Interactor,
      input: [:some_value],
      output: [:some_result],
      error: [:number]

    def test_ok, do: ok()
    def test_error, do: error()
    def test_ok_value, do: ok(some_result: "result")
    def test_error_value, do: error("test", number: 1)
    def test_error_value_only_message, do: error("test")
  end

  describe "UseCase.Interactor.__using__/1" do
    test "creates the ok and error macro" do
      assert FakeUC.test_ok() == {:ok, %FakeUC.Output{}}
      assert FakeUC.test_error() == {:error, %FakeUC.Error{}}
      assert FakeUC.test_ok_value() == {:ok, %FakeUC.Output{some_result: "result"}}
      assert FakeUC.test_error_value() == {:error, %FakeUC.Error{message: "test", number: 1}}

      assert FakeUC.test_error_value_only_message() ==
               {:error, %FakeUC.Error{message: "test", number: nil}}
    end
  end
end
