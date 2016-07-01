defmodule ComfortablyEnum do
  @doc """
  Map - do a thing to all the things

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
end
