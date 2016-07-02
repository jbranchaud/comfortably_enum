defmodule ComfortablyEnum do
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
  def all?(list, func \\ fn(x) -> !!x end), do: reduce(list, true, &(func.(&1) && &2))

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
  def any?(list, func \\ fn(x) -> !!x end), do: reduce(list, false, &(func.(&1) || &2))

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

  @doc false
  defmodule EmptyError do
    defexception message: "empty error"
  end
end
