defmodule RaspDemoTest do
  use ExUnit.Case
  doctest RaspDemo

  test "greets the world" do
    assert RaspDemo.hello() == :world
  end
end
