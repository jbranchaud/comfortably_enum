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

  test "chunk/2" do
    assert ComfortablyEnum.chunk([1,2,3,4], 2) == [[1, 2], [3, 4]]
    assert ComfortablyEnum.chunk([1,2,3], 4) == []
    assert_raise FunctionClauseError, ~r/^no function clause matching/, fn ->
      ComfortablyEnum.chunk([1,2,3], 0)
    end
  end

  test "chunk/3" do
    assert ComfortablyEnum.chunk([1,2,3,4], 2, 2) == [[1, 2], [3, 4]]
    assert ComfortablyEnum.chunk([1,2,3], 2, 1) == [[1, 2], [2, 3]]
    assert ComfortablyEnum.chunk([1,2,3,4,5], 3, 3) == [[1, 2, 3]]
  end

  test "chunk/4" do
    assert ComfortablyEnum.chunk([1,2,3,4,5], 3, 3, []) == [[1, 2, 3], [4, 5]]
    assert ComfortablyEnum.chunk([1,2,3], 4, 4, []) == [[1,2,3]]
    assert ComfortablyEnum.chunk([1,2,3], 2, 2, [4]) == [[1, 2], [3, 4]]
    assert ComfortablyEnum.chunk([1,2,3,4], 3, 1, [5,6]) == [[1, 2, 3], [2, 3, 4], [3, 4, 5]]
  end

  test "concat/1" do
    assert ComfortablyEnum.concat([[1,2,3], [4,5,6]]) == [1, 2, 3, 4, 5, 6]
    assert ComfortablyEnum.concat([[1], [2], [3]]) == [1, 2, 3]
    assert ComfortablyEnum.concat([[1, [2]], [[3], 4]]) == [1, [2], [3], 4]
    assert ComfortablyEnum.concat([]) == []
    assert ComfortablyEnum.concat([[], []]) == []
  end

  test "concat/2" do
    assert ComfortablyEnum.concat([1,2,3], [3,4,5]) == [1, 2, 3, 3, 4, 5]
    assert ComfortablyEnum.concat([], [2,3]) == [2, 3]
    assert ComfortablyEnum.concat([1,2], []) == [1, 2]
    assert ComfortablyEnum.concat([], []) == []
  end

  test "count/1" do
    assert ComfortablyEnum.count([]) == 0
    assert ComfortablyEnum.count([1,2,3,4,5]) == 5
  end

  test "count/2" do
    assert ComfortablyEnum.count([1,2,3], &(&1 > 0)) == 3
    assert ComfortablyEnum.count([1,2,3], &(rem(&1, 2) == 0)) == 1
    assert ComfortablyEnum.count([nil, false, true], &(!!&1)) == 1
    assert ComfortablyEnum.count([], &(&1 > 2)) == 0
  end

  test "dedup/1" do
    assert ComfortablyEnum.dedup([1,2,2,3]) == [1,2,3]
    assert ComfortablyEnum.dedup([:one, :one, 2, 3, 3, 2, :one]) == [:one, 2, 3, 2, :one]
    assert ComfortablyEnum.dedup([]) == []
    assert ComfortablyEnum.dedup([1]) == [1]
    assert ComfortablyEnum.dedup([1, 1, 2, 2.0, :three, :"three"]) == [1, 2, 2.0, :three]
  end

  test "drop/2" do
    assert ComfortablyEnum.drop([1,2,3], 1) == [2, 3]
    assert ComfortablyEnum.drop([1,2,3], 2) == [3]
    assert ComfortablyEnum.drop([1,2,3], 4) == []
    assert ComfortablyEnum.drop([1,2,3], 0) == [1,2,3]
    assert ComfortablyEnum.drop([1,2,3], -1) == [1,2,3]
  end

  test "index_of/2" do
    assert ComfortablyEnum.index_of([1,2,3], 3) == 2
    assert ComfortablyEnum.index_of([:a,:b,:c], :a) == 0
    assert ComfortablyEnum.index_of([], 0) == -1
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
