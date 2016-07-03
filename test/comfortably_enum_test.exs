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

  test "any?/2" do
    assert ComfortablyEnum.any?([]) == false
    assert ComfortablyEnum.any?([1,2,3]) == true
    assert ComfortablyEnum.any?([false, nil]) == false
    assert ComfortablyEnum.any?([false, false, true]) == true
    assert ComfortablyEnum.any?([1,2,3], fn(x) -> x < 0 end) == false
    assert ComfortablyEnum.any?([1,2,3], fn(x) -> rem(x, 2) == 0 end) == true
  end

  test "at/2" do
    assert ComfortablyEnum.at([], 1) == nil
    assert ComfortablyEnum.at([1,2,3], 0) == 1
    assert ComfortablyEnum.at([1,2,3], 5) == nil
    assert ComfortablyEnum.at([], 1, :not_found) == :not_found
    assert ComfortablyEnum.at([1,2,3], -1, 0) == 0
  end

  test "count/1" do
    assert ComfortablyEnum.count([]) == 0
    assert ComfortablyEnum.count([1,2,3,4,5]) == 5
  end

  test "drop/2" do
    assert ComfortablyEnum.drop([1,2,3], 1) == [2, 3]
    assert ComfortablyEnum.drop([1,2,3], 2) == [3]
    assert ComfortablyEnum.drop([1,2,3], 4) == []
    assert ComfortablyEnum.drop([1,2,3], 0) == [1,2,3]
    assert ComfortablyEnum.drop([1,2,3], -1) == [1,2,3]
  end

  test "map/2" do
    assert ComfortablyEnum.map([]) == []
    assert ComfortablyEnum.map([], fn(x) -> x * x end) == []
    assert ComfortablyEnum.map([1,2,3]) == [1,2,3]
    assert ComfortablyEnum.map([1,2,3], fn(x) -> x * x end) == [1,4,9]
    assert ComfortablyEnum.map([1,true,"wat"], &to_string/1) == ["1", "true", "wat"]
  end

  test "reduce/2" do
    adder = fn(a, b) -> a + b end
    appender = fn(a, b) -> b <> " - " <> a end

    assert_raise ComfortablyEnum.EmptyError, "empty error", fn ->
      ComfortablyEnum.reduce([], adder)
    end
    assert ComfortablyEnum.reduce([1,2,3], adder) == 6
    assert ComfortablyEnum.reduce(["one", "two", "three"], appender) == "one - two - three"
  end

  test "reduce/3" do
    adder = fn(a, b) -> a + b end

    assert ComfortablyEnum.reduce([], 1, adder) == 1
    assert ComfortablyEnum.reduce([1,2,3], [], fn(x, acc) -> acc ++ [x * x] end) == [1,4,9]
    assert ComfortablyEnum.reduce([1,2,3], %{}, fn(x, acc) -> Map.put(acc, x, x + x) end) == %{1 => 2, 2 => 4, 3 => 6}
  end

  test "take/2" do
    assert ComfortablyEnum.take([1,2,3], 1) == [1]
    assert ComfortablyEnum.take([1,2,3], 2) == [1, 2]
    assert ComfortablyEnum.take([1,2,3], 4) == [1, 2, 3]
    assert ComfortablyEnum.take([1,2,3], -1) == []
    assert ComfortablyEnum.take([1,2,3], 0) == []
  end
end
