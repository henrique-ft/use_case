defmodule UseCaseTest do
  use ExUnit.Case, async: true
  alias UseCase

  defmodule FakeInteractor do
    @moduledoc """
      My interactor
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

    def call(%{some_value: "test"} = input, opts) do
      send(self(), {input, opts})

      ok(some_result: "result")
    end

    def call(%{} = input, opts), do: send(self(), {input, opts})

    def call(input, opts) do
      send(self(), {input, opts})

      ok(some_result: "result")
    end
  end

  defmodule FakeInteractorTwo do
    use UseCase.Interactor

    def call(input, [{:my_option, "fail_two"}] = opts) do
      send(self(), {input, opts})

      error()
    end

    def call(input, opts) do
      send(self(), {input, opts})

      ok()
    end
  end

  defmodule FakeInteractorThree do
    use UseCase.Interactor

    def call(input, opts) do
      send(self(), {input, opts})

      ok()
    end
  end

  describe "UseCase.pipe/1" do
    test "it call's interactors with correct params" do
      interactors = [%FakeInteractor{some_value: "test"}, FakeInteractorTwo, FakeInteractorThree]
      result = UseCase.pipe(interactors)

      assert_received {%FakeInteractor{some_value: "test"}, []}
      assert_received {%FakeInteractor.Output{}, []}
      assert_received {%FakeInteractorTwo.Output{}, []}
      assert result == {:ok, %FakeInteractorThree.Output{}}
    end
  end

  describe "UseCase.pipe/2" do
    test "it call's interactors with correct params and opts" do
      interactors = [%FakeInteractor{some_value: "test"}, FakeInteractorTwo, FakeInteractorThree]
      result = UseCase.pipe(interactors, my_option: "test")

      assert_received {%FakeInteractor{some_value: "test"}, [my_option: "test"]}
      assert_received {%FakeInteractor.Output{}, [my_option: "test"]}
      assert_received {%FakeInteractorTwo.Output{}, [my_option: "test"]}
      assert result == {:ok, %FakeInteractorThree.Output{}}
    end
  end

  describe "UseCase.pipe/3" do
    test "it call's interactors with correct params and opts" do
      interactors = [FakeInteractor, FakeInteractorTwo, FakeInteractorThree]
      result = UseCase.pipe(interactors, %{some_value: "test"}, my_option: "test")

      assert_received {%{some_value: "test"}, [my_option: "test"]}
      assert_received {%FakeInteractor.Output{}, [my_option: "test"]}
      assert_received {%FakeInteractorTwo.Output{}, [my_option: "test"]}
      assert result == {:ok, %FakeInteractorThree.Output{}}
    end

    test "if some interactor fails, returns the failed return" do
      interactors = [FakeInteractor, FakeInteractorTwo, FakeInteractorThree]
      result = UseCase.pipe(interactors, %{some_value: "test"}, my_option: "fail_two")

      assert_received {%{some_value: "test"}, [my_option: "fail_two"]}
      assert_received {%FakeInteractor.Output{}, [my_option: "fail_two"]}
      refute_received {%FakeInteractorTwo.Output{}, [my_option: "fail_two"]}
      assert result == {:error, %FakeInteractorTwo.Error{}}
    end
  end

  describe "UseCase.pipe!/3" do
    test "it call's interactors with correct params and opts" do
      interactors = [FakeInteractor, FakeInteractorTwo, FakeInteractorThree]
      result = UseCase.pipe!(interactors, %{some_value: "test"}, my_option: "test")

      assert_received {%{some_value: "test"}, [my_option: "test"]}
      assert_received {%FakeInteractor.Output{}, [my_option: "test"]}
      assert_received {%FakeInteractorTwo.Output{}, [my_option: "test"]}
      assert result == %FakeInteractorThree.Output{}
    end

    test "if some interactor fails, raises the failed return" do
      interactors = [FakeInteractor, FakeInteractorTwo, FakeInteractorThree]

      assert_raise FakeInteractorTwo.Error, fn ->
        UseCase.pipe!(interactors, %{some_value: "test"}, my_option: "fail_two")
      end

      assert_received {%{some_value: "test"}, [my_option: "fail_two"]}
      assert_received {%FakeInteractor.Output{}, [my_option: "fail_two"]}
      refute_received {%FakeInteractorTwo.Output{}, [my_option: "fail_two"]}
    end
  end

  describe "UseCase.call/1" do
    test "it call's interactor with correct params and opts" do
      result = UseCase.call(%FakeInteractor{some_value: "test"})

      assert_received {%FakeInteractor{some_value: "test"}, []}
      assert result == {:ok, %FakeInteractor.Output{some_result: "result"}}
    end

    test "if single atom given, it calls interactor with empty params" do
      UseCase.call(FakeInteractor)

      assert_received {%{}, []}
    end
  end

  describe "UseCase.call/2" do
    test "it call's interactor with correct params and opts" do
      result = UseCase.call(%FakeInteractor{some_value: "test"}, "opts")

      assert_received {%FakeInteractor{some_value: "test"}, "opts"}
      assert result == {:ok, %FakeInteractor.Output{some_result: "result"}}
    end

    test "it call's interactor with correct params" do
      result = UseCase.call(FakeInteractor, "params")

      assert_received {"params", []}
      assert result == {:ok, %FakeInteractor.Output{some_result: "result"}}
    end
  end

  describe "UseCase.call/3" do
    test "it call's interactor with correct params and opts" do
      result = UseCase.call(FakeInteractor, "params", "opts")

      assert_received {"params", "opts"}
      assert result == {:ok, %FakeInteractor.Output{some_result: "result"}}
    end
  end

  describe "UseCase.call errors" do
    test "its raises an interactor error" do
      result = UseCase.call(%FakeInteractor{some_value: "wrong_value"})

      assert_received {%FakeInteractor{some_value: "wrong_value"}, []}
      assert result == {:error, %FakeInteractor.Error{message: "Wrong value given", number: 1}}
    end
  end

  describe "UseCase.call!/1" do
    test "it call's interactor with correct params and opts" do
      result = UseCase.call!(%FakeInteractor{some_value: "test"})

      assert_received {%FakeInteractor{some_value: "test"}, []}
      assert result == %FakeInteractor.Output{some_result: "result"}
    end

    test "if single atom given, it calls interactor with empty params" do
      UseCase.call(FakeInteractor)

      assert_received {%{}, []}
    end
  end

  describe "UseCase.call!/2" do
    test "it call's interactor with correct params and opts" do
      result = UseCase.call!(%FakeInteractor{some_value: "test"}, "opts")

      assert_received {%FakeInteractor{some_value: "test"}, "opts"}
      assert result == %FakeInteractor.Output{some_result: "result"}
    end

    test "it call's interactor with correct params" do
      result = UseCase.call!(FakeInteractor, "params")

      assert_received {"params", []}
      assert result == %FakeInteractor.Output{some_result: "result"}
    end
  end

  describe "UseCase.call!/3" do
    test "it call's interactor with correct params and opts" do
      result = UseCase.call!(FakeInteractor, "params", "opts")

      assert_received {"params", "opts"}
      assert result == %FakeInteractor.Output{some_result: "result"}
    end
  end

  describe "UseCase.call! errors" do
    test "its raises an interactor error" do
      assert_raise FakeInteractor.Error, fn ->
        UseCase.call!(%FakeInteractor{some_value: "wrong_value"})
      end

      assert_received {%FakeInteractor{some_value: "wrong_value"}, []}
    end
  end
end
