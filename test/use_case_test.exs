defmodule UseCaseTest do
  use ExUnit.Case
  doctest UseCase

  test "greets the world" do
    assert UseCase.hello() == :world
  end
end
