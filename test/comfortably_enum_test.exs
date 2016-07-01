defmodule ComfortablyEnumTest do
  use ExUnit.Case
  doctest ComfortablyEnum

  test "map/2" do
    assert ComfortablyEnum.map([]) == []
    assert ComfortablyEnum.map([], fn(x) -> x * x end) == []
    assert ComfortablyEnum.map([1,2,3]) == [1,2,3]
    assert ComfortablyEnum.map([1,2,3], fn(x) -> x * x end) == [1,4,9]
    assert ComfortablyEnum.map([1,true,"wat"], &to_string/1) == ["1", "true", "wat"]
  end
end
