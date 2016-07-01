defmodule ComfortablyEnumTest do
  use ExUnit.Case
  doctest ComfortablyEnum

  test "all?/2" do
    assert ComfortablyEnum.all?([]) == true
    assert ComfortablyEnum.all?([1,2,3]) == true
    assert ComfortablyEnum.all?([true, false, true]) == false
    assert ComfortablyEnum.all?(["one", "two", nil]) == false
    assert ComfortablyEnum.all?([1,2,3], fn(x) -> x > 0 end) == true
    assert ComfortablyEnum.all?([1,2,3], fn(x) -> rem(x, 2) == 0 end) == false
  end

  test "map/2" do
    assert ComfortablyEnum.map([]) == []
    assert ComfortablyEnum.map([], fn(x) -> x * x end) == []
    assert ComfortablyEnum.map([1,2,3]) == [1,2,3]
    assert ComfortablyEnum.map([1,2,3], fn(x) -> x * x end) == [1,4,9]
    assert ComfortablyEnum.map([1,true,"wat"], &to_string/1) == ["1", "true", "wat"]
  end

  test "count/1" do
    assert ComfortablyEnum.count([]) == 0
    assert ComfortablyEnum.count([1,2,3,4,5]) == 5
  end
end
