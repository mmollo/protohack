defmodule ProtohackTest do
  use ExUnit.Case
  doctest Protohack

  test "greets the world" do
    assert Protohack.hello() == :world
  end
end
