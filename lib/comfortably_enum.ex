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
  concat - combine a list of lists into a single list

      iex> ComfortablyEnum.concat([[1,2,3], [4,5,6]])
      [1, 2, 3, 4, 5, 6]
      iex> ComfortablyEnum.concat([[1], [2], [3]])
      [1, 2, 3]
      iex> ComfortablyEnum.concat([[1, [2]], [[3], 4]])
      [1, [2], [3], 4]

  """
  def concat(list), do: reduce(list, [], &(&2 ++ &1))

  @doc """
  count - count the things

      iex> ComfortablyEnum.count([])
      0
      iex> ComfortablyEnum.count([1,2,3,4,5])
      5

  """
  def count(list), do: count(list, 0)
  defp count([], count), do: count
  defp count([_head | tail], count) do
    count(tail, count + 1)
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
  map - do a thing to all the things

    iex> ComfortablyEnum.map([1,2,3])
    [1,2,3]
    iex> ComfortablyEnum.map([1,2,3], fn(x) -> x * x end)
    [1,4,9]
    iex> ComfortablyEnum.map([1,2,3], &to_string/1)
    ["1","2","3"]

  """
  def map(list, func \\ fn(x) -> x end)
  def map([], _func), do: []
  def map([head | tail], func), do: [func.(head) | map(tail, func)]

  @doc """
  reduce - accumulate the result of doing a thing to the things

      iex> ComfortablyEnum.reduce([1,2,3], fn(x, acc) -> acc + x end)
      6
      iex> ComfortablyEnum.reduce([], fn(x, acc) -> acc + x end)
      ** (ComfortablyEnum.EmptyError) empty error
      iex> appender = fn(x, acc) -> acc <> " - " <> x end
      iex> ComfortablyEnum.reduce(["one", "two", "three"], appender)
      "one - two - three"
      iex> ComfortablyEnum.reduce([], 1, fn(x, acc) -> acc + x end)
      1
      iex> ComfortablyEnum.reduce([1,2,3], %{}, fn(x, acc) -> Map.put(acc, x, x * x) end)
      %{1 => 1, 2 => 4, 3 => 9}
  """
  def reduce([], _func), do: raise ComfortablyEnum.EmptyError
  def reduce([head | tail], func), do: reduce(tail, head, func)
  def reduce([], acc, _func), do: acc
  def reduce([head | tail], acc, func), do: reduce(tail, func.(head, acc), func)

  @doc """
  take - take some things from the list

      iex> ComfortablyEnum.take([1,2,3], 1)
      [1]
      iex> ComfortablyEnum.take([1,2,3], 2)
      [1, 2]
      iex> ComfortablyEnum.take([1,2,3], 4)
      [1, 2, 3]

  """
  def take([], _n), do: []
  def take(_list, n) when n <= 0, do: []
  def take([head | tail], n), do: [head | take(tail, n - 1)]

  defmodule EmptyError do
    defexception message: "empty error"
  end
end
