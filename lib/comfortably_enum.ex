defmodule ComfortablyEnum do
  @moduledoc """
  Enumerables in Elixir
  """

  @doc """
  all? - check that all the things check out

      iex> ComfortablyEnum.all?([])
      true
      iex> ComfortablyEnum.all?([1,2,3])
      true
      iex> ComfortablyEnum.all?([true,false,true])
      false
      iex> ComfortablyEnum.all?([1,2,3], fn(x) -> x > 0 end)
      true

  """
  def all?(list, func \\ &(!!&1)), do: reduce(list, true, &(func.(&1) && &2))

  @doc """
  any? - check that some of the things check out

      iex> ComfortablyEnum.any?([])
      false
      iex> ComfortablyEnum.any?([1,2,3])
      true
      iex> ComfortablyEnum.any?([false,false,true])
      true
      iex> ComfortablyEnum.any?([1,2,3], fn(x) -> x < 0 end)
      false

  """
  def any?(list, func \\ &(!!&1)), do: reduce(list, false, &(func.(&1) || &2))

  @doc """
  at - get the thing that is at the 0-based index

      iex> ComfortablyEnum.at([], 1)
      nil
      iex> ComfortablyEnum.at([1,2,3], 0)
      1
      iex> ComfortablyEnum.at([1,2,3], 5)
      nil
      iex> ComfortablyEnum.at([], 1, :not_found)
      :not_found
  """
  def at(list, index, default \\ nil)
  def at([], _index, default), do: default
  def at([head | _tail], 0, _default), do: head
  def at([_head | tail], index, default), do: at(tail, index - 1, default)

  @doc """
  chunk - group the things together in sets based on count and step

      iex> ComfortablyEnum.chunk([1,2,3,4], 2)
      [[1, 2], [3, 4]]
      iex> ComfortablyEnum.chunk([1,2,3,4], 2, 2)
      [[1, 2], [3, 4]]
      iex> ComfortablyEnum.chunk([1,2,3], 2, 1)
      [[1, 2], [2, 3]]
      iex> ComfortablyEnum.chunk([1,2,3,4,5], 3, 3)
      [[1, 2, 3]]
      iex> ComfortablyEnum.chunk([1,2,3,4,5], 3, 3, [])
      [[1, 2, 3], [4, 5]]
      iex> ComfortablyEnum.chunk([1,2,3], 4)
      []
      iex> ComfortablyEnum.chunk([1,2,3], 4, 4, [])
      [[1,2,3]]
      iex> ComfortablyEnum.chunk([1,2,3], 2, 2, [4])
      [[1, 2], [3, 4]]

  """
  def chunk(list, count, step \\ nil, leftover \\ nil) when count > 0 do
    chunk(list, count(list), count, step || count, leftover)
  end
  def chunk([], _list_size, _count, _step, _leftover), do: []
  def chunk(_list, list_size, count, _step, nil) when list_size < count, do: []
  def chunk(list, list_size, count, _step, leftover) when list_size < count do
    [take(list ++ leftover, count)]
  end
  def chunk(list, list_size, count, step, leftover) do
    [take(list, count)] ++ chunk(drop(list, step), list_size - step, count, step, leftover)
  end

  @doc """
  concat/1 - combine a list of lists into a single list

      iex> ComfortablyEnum.concat([[1,2,3], [4,5,6]])
      [1, 2, 3, 4, 5, 6]
      iex> ComfortablyEnum.concat([[1], [2], [3]])
      [1, 2, 3]
      iex> ComfortablyEnum.concat([[1, [2]], [[3], 4]])
      [1, [2], [3], 4]

  """
  def concat(list), do: reduce(list, [], &(&2 ++ &1))

  @doc """
  concat/2 - combine two lists into a single list

      iex> ComfortablyEnum.concat([1,2,3], [3,4,5])
      [1, 2, 3, 3, 4, 5]
      iex> ComfortablyEnum.concat([], [2,3])
      [2, 3]
      iex> ComfortablyEnum.concat([1,2], [])
      [1, 2]

  """
  def concat(left, right), do: left ++ right

  @doc """
  count/1 - count the things

      iex> ComfortablyEnum.count([])
      0
      iex> ComfortablyEnum.count([1,2,3,4,5])
      5

  """
  def count(list), do: do_count(list, 0)

  defp do_count([], total) when is_number(total), do: total
  defp do_count([_head | tail], total) when is_number(total), do: do_count(tail, total + 1)

  @doc """
  count/2 - count the things that are truthy to the function

      iex> ComfortablyEnum.count([1,2,3], &(&1 > 0))
      3
      iex> ComfortablyEnum.count([1,2,3], &(rem(&1, 2) == 0))
      1
      iex> ComfortablyEnum.count([nil, false, true], &(!!&1))
      1

  """
  def count(list, func) when is_function(func, 1), do: do_count(list, func, 0)

  defp do_count([], _func, total), do: total
  defp do_count([head | tail], func, total) do
    if func.(head) do do_count(tail, func, total + 1); else do_count(tail, func, total) end
  end

  @doc """
  dedup/1 - remove all subsequently duplicate things

      iex> ComfortablyEnum.dedup([1,2,2,3])
      [1,2,3]
      iex> ComfortablyEnum.dedup([:one, :one, 2, 3, 3, 2, :one])
      [:one, 2, 3, 2, :one]

  """
  def dedup([]), do: []
  def dedup([head | tail]), do: do_dedup(tail, [head], head)

  defp do_dedup([], acc, _prev), do: :lists.reverse(acc)
  defp do_dedup([head | tail], acc,  prev) do
    acc =
      unless head === prev do
        [head | acc]
      end || acc
    do_dedup(tail, acc, head)
  end

  @doc """
  drop - drop some things from the list

      iex> ComfortablyEnum.drop([1,2,3], 1)
      [2, 3]
      iex> ComfortablyEnum.drop([1,2,3], 2)
      [3]
      iex> ComfortablyEnum.drop([1,2,3], 4)
      []

  """
  def drop([], _n), do: []
  def drop(list, n) when n <= 0, do: list
  def drop([_head | tail], n), do: drop(tail, n - 1)

  @doc """
  index_of - get the index of the thing

      iex> ComfortablyEnum.index_of([1,2,3], 3)
      2
      iex> ComfortablyEnum.index_of([:a,:b,:c], :a)
      0
      iex> ComfortablyEnum.index_of([], 0)
      -1

  """
  def index_of(list, item), do: do_index_of(list, item, 0)

  defp do_index_of([], _item, _curr_index), do: -1
  defp do_index_of([head | _tail], item, curr_index) when head == item do
    curr_index
  end
  defp do_index_of([_head | tail], item, curr_index) do
    do_index_of(tail, item, curr_index + 1)
  end

  @doc """
  map - do a thing to all the things

    iex> ComfortablyEnum.map([1,2,3])
    [1,2,3]
    iex> ComfortablyEnum.map([1,2,3], fn(x) -> x * x end)
    [1,4,9]
    iex> ComfortablyEnum.map([1,2,3], &to_string/1)
    ["1","2","3"]

  """
  def map(list, func \\ fn(x) -> x end), do: do_map(list, func, [])

  defp do_map([], _func, acc), do: :lists.reverse(acc)
  defp do_map([head | tail], func, acc) do
    acc = [func.(head) | acc]
    do_map(tail, func, acc)
  end

  @doc """
  reduce/2 - accumulate the result of doing a thing to the things

      iex> ComfortablyEnum.reduce([1,2,3], fn(x, acc) -> acc + x end)
      6
      iex> ComfortablyEnum.reduce([], fn(x, acc) -> acc + x end)
      ** (ComfortablyEnum.EmptyError) empty error
      iex> appender = fn(x, acc) -> acc <> " - " <> x end
      iex> ComfortablyEnum.reduce(["one", "two", "three"], appender)
      "one - two - three"

  """
  def reduce([], _func), do: raise ComfortablyEnum.EmptyError
  def reduce([head | tail], func) when is_function(func) do
    do_reduce(tail, head, func)
  end

  defp do_reduce([], acc, _func), do: acc
  defp do_reduce([head | tail], acc, func) do
    acc = func.(head, acc)
    reduce(tail, acc, func)
  end

  @doc """
  reduce/3

      iex> ComfortablyEnum.reduce([], 1, fn(x, acc) -> acc + x end)
      1
      iex> ComfortablyEnum.reduce([1,2,3], %{}, fn(x, acc) -> Map.put(acc, x, x * x) end)
      %{1 => 1, 2 => 4, 3 => 9}

  """
  def reduce(list, acc, func) when is_function(func) do
    do_reduce(list, acc, func)
  end


  @doc """
  take - take some things from the list

      iex> ComfortablyEnum.take([1,2,3], 1)
      [1]
      iex> ComfortablyEnum.take([1,2,3], 2)
      [1, 2]
      iex> ComfortablyEnum.take([1,2,3], 4)
      [1, 2, 3]

  """
  def take(list, n), do: do_take(list, n, [])

  defp do_take([], _n, acc), do: :lists.reverse(acc)
  defp do_take(_list, n, acc) when n <= 0, do: :lists.reverse(acc)
  defp do_take([head | tail], n, acc) do
    acc = [head | acc]
    do_take(tail, n - 1, acc)
  end

  defmodule EmptyError do
    defexception message: "empty error"
  end
end
