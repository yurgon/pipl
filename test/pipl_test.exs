defmodule PiplTest do
  use ExUnit.Case
  doctest Pipl

  test "greets the world" do
    assert Pipl.hello() == :world
  end
end
