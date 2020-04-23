defmodule UseCaseTest do
  use ExUnit.Case, async: true
  alias UseCase

  defmodule FakeUC do
    @moduledoc """
      My use case
    """
    use UseCase,
      input: [:some_value],
      output: [:some_result],
      error: [:number]

    def call(%__MODULE__{some_value: "wrong_value"} = input, opts) do
      send(self(), {input, opts})

      error("Wrong value given", number: 1)
    end

    def call(%__MODULE__{} = input, opts) do
      send(self(), {input, opts})

      ok(some_result: "result")
    end

    def call(input, opts) do
      send(self(), {input, opts})

      ok(some_result: "result")
    end

    def test_ok, do: ok()
    def test_error, do: error()
    def test_ok_value, do: ok(some_result: "result")
    def test_error_value, do: error("test", number: 1)
    def test_error_value_only_message, do: error("test")
  end

  defmodule FaceUC2 do
    @moduledoc """
      My use case
    """
    use UseCase

    def call(%{"value" => "wrong_value"} = input, opts) do
      send(self(), {input, opts})

      error("Wrong value given")
    end
  end

  describe "Using UseCase" do
    test "creates the ok and error macro" do
      assert FakeUC.test_ok() == {:ok, %FakeUC.Output{}}
      assert FakeUC.test_error() == {:error, %FakeUC.Error{}}
      assert FakeUC.test_ok_value() == {:ok, %FakeUC.Output{some_result: "result"}}
      assert FakeUC.test_error_value() == {:error, %FakeUC.Error{message: "test", number: 1}}

      assert FakeUC.test_error_value_only_message() ==
               {:error, %FakeUC.Error{message: "test", number: nil}}
    end
  end

  # UseCase.call

  describe "UseCase.call/1" do
    test "it call's usecase with correct params and opts" do
      result = UseCase.call(%FakeUC{some_value: "test"})

      assert_received {%FakeUC{some_value: "test"}, []}
      assert result == {:ok, %FakeUC.Output{some_result: "result"}}
    end
  end

  describe "UseCase.call/2" do
    test "it call's usecase with correct params and opts" do
      result = UseCase.call(%FakeUC{some_value: "test"}, "opts")

      assert_received {%FakeUC{some_value: "test"}, "opts"}
      assert result == {:ok, %FakeUC.Output{some_result: "result"}}
    end

    test "it call's usecase with correct params" do
      result = UseCase.call(FakeUC, "params")

      assert_received {"params", []}
      assert result == {:ok, %FakeUC.Output{some_result: "result"}}
    end
  end

  describe "UseCase.call/3" do
    test "it call's usecase with correct params and opts" do
      result = UseCase.call(FakeUC, "params", "opts")

      assert_received {"params", "opts"}
      assert result == {:ok, %FakeUC.Output{some_result: "result"}}
    end
  end

  describe "UseCase.call errors" do
    test "its raises an usecase error" do
      result = UseCase.call(%FakeUC{some_value: "wrong_value"})

      assert_received {%FakeUC{some_value: "wrong_value"}, []}
      assert result == {:error, %FakeUC.Error{message: "Wrong value given", number: 1}}
    end
  end

  # UseCase.call!

  describe "UseCase.call!/1" do
    test "it call's usecase with correct params and opts" do
      result = UseCase.call!(%FakeUC{some_value: "test"})

      assert_received {%FakeUC{some_value: "test"}, []}
      assert result == %FakeUC.Output{some_result: "result"}
    end
  end

  describe "UseCase.call!/2" do
    test "it call's usecase with correct params and opts" do
      result = UseCase.call!(%FakeUC{some_value: "test"}, "opts")

      assert_received {%FakeUC{some_value: "test"}, "opts"}
      assert result == %FakeUC.Output{some_result: "result"}
    end

    test "it call's usecase with correct params" do
      result = UseCase.call!(FakeUC, "params")

      assert_received {"params", []}
      assert result == %FakeUC.Output{some_result: "result"}
    end
  end

  describe "UseCase.call!/3" do
    test "it call's usecase with correct params and opts" do
      result = UseCase.call!(FakeUC, "params", "opts")

      assert_received {"params", "opts"}
      assert result == %FakeUC.Output{some_result: "result"}
    end
  end

  describe "UseCase.call! errors" do
    test "its raises an usecase error" do
      assert_raise FakeUC.Error, fn ->
        UseCase.call!(%FakeUC{some_value: "wrong_value"})
      end

      assert_received {%FakeUC{some_value: "wrong_value"}, []}
    end
  end
end
