defmodule UseCaseTest do
  use ExUnit.Case, async: true
  alias UseCase

  defmodule FakeInteractor do
    @moduledoc """
      My use case
    """
    use UseCase.Interactor,
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
  end

  describe "UseCase.call/1" do
    test "it call's usecase with correct params and opts" do
      result = UseCase.call(%FakeInteractor{some_value: "test"})

      assert_received {%FakeInteractor{some_value: "test"}, []}
      assert result == {:ok, %FakeInteractor.Output{some_result: "result"}}
    end
  end

  describe "UseCase.call/2" do
    test "it call's usecase with correct params and opts" do
      result = UseCase.call(%FakeInteractor{some_value: "test"}, "opts")

      assert_received {%FakeInteractor{some_value: "test"}, "opts"}
      assert result == {:ok, %FakeInteractor.Output{some_result: "result"}}
    end

    test "it call's usecase with correct params" do
      result = UseCase.call(FakeInteractor, "params")

      assert_received {"params", []}
      assert result == {:ok, %FakeInteractor.Output{some_result: "result"}}
    end
  end

  describe "UseCase.call/3" do
    test "it call's usecase with correct params and opts" do
      result = UseCase.call(FakeInteractor, "params", "opts")

      assert_received {"params", "opts"}
      assert result == {:ok, %FakeInteractor.Output{some_result: "result"}}
    end
  end

  describe "UseCase.call errors" do
    test "its raises an usecase error" do
      result = UseCase.call(%FakeInteractor{some_value: "wrong_value"})

      assert_received {%FakeInteractor{some_value: "wrong_value"}, []}
      assert result == {:error, %FakeInteractor.Error{message: "Wrong value given", number: 1}}
    end
  end

  describe "UseCase.call!/1" do
    test "it call's usecase with correct params and opts" do
      result = UseCase.call!(%FakeInteractor{some_value: "test"})

      assert_received {%FakeInteractor{some_value: "test"}, []}
      assert result == %FakeInteractor.Output{some_result: "result"}
    end
  end

  describe "UseCase.call!/2" do
    test "it call's usecase with correct params and opts" do
      result = UseCase.call!(%FakeInteractor{some_value: "test"}, "opts")

      assert_received {%FakeInteractor{some_value: "test"}, "opts"}
      assert result == %FakeInteractor.Output{some_result: "result"}
    end

    test "it call's usecase with correct params" do
      result = UseCase.call!(FakeInteractor, "params")

      assert_received {"params", []}
      assert result == %FakeInteractor.Output{some_result: "result"}
    end
  end

  describe "UseCase.call!/3" do
    test "it call's usecase with correct params and opts" do
      result = UseCase.call!(FakeInteractor, "params", "opts")

      assert_received {"params", "opts"}
      assert result == %FakeInteractor.Output{some_result: "result"}
    end
  end

  describe "UseCase.call! errors" do
    test "its raises an usecase error" do
      assert_raise FakeInteractor.Error, fn ->
        UseCase.call!(%FakeInteractor{some_value: "wrong_value"})
      end

      assert_received {%FakeInteractor{some_value: "wrong_value"}, []}
    end
  end
end
