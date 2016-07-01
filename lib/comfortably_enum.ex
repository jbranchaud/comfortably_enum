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
  def all?(list, func \\ fn(x) -> !!x end)
  def all?([], _func), do: true
  def all?([head | tail], func), do: func.(head) && all?(tail, func)

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
end
