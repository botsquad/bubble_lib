defmodule BubbleLib.MapUtil.AutoMap.ETS do
  defstruct table: nil, match_state: nil, creator: nil

  alias BubbleLib.MapUtil.AutoMap.ETS
  alias BubbleLib.MapUtil.AutoMap

  def new(data \\ [], opts \\ []) do
    {opts, ets_opts} = Keyword.split(opts, [:creator, :name])

    table =
      case opts[:name] do
        nil ->
          if opts[:creator] != nil do
            raise RuntimeError, "Cannot set ETS creator function for non-named tables"
          end

          :ets.new(:table, [:ordered_set | ets_opts])

        name ->
          :ets.new(name, [:named_table, :ordered_set | ets_opts])
          name
      end

    reset(%ETS{table: table, creator: opts[:creator]}, data)
  end

  def reset(%ETS{table: table} = ets, data) do
    ets_retry(fn -> :ets.delete_all_objects(table) end, ets.creator)
    # load the data
    data
    |> Enum.reduce(0, fn row, index ->
      true = :ets.insert(table, {index, row})
      index + 1
    end)

    # return the struct
    ets
  end

  def get_in(%ETS{table: table} = ets, [index | rest]) when is_integer(index) do
    lookup = ets_retry(fn -> :ets.lookup(table, index) end, ets.creator)

    case lookup do
      [] ->
        nil

      [{_index, entry}] ->
        AutoMap.get_in(entry, rest)
    end
  end

  def get_in(%ETS{} = ets, [query | tail]) when is_list(query) do
    AutoMap.get_in(MatchEngine.filter_all(ets, query), tail)
  end

  def get_in(value, []) do
    value
  end

  def get_in(_, _p) do
    nil
  end

  def loop_start(ets) do
    match_state = ets_retry(fn -> :ets.match(ets.table, :"$1", 1) end, ets.creator)
    %ETS{ets | match_state: match_state}
  end

  def loop_next(%ETS{match_state: :"$end_of_table"}) do
    :stop
  end

  def loop_next(%ETS{match_state: {[[{_index, row}]], continuation}} = ets) do
    match_state = ets_retry(fn -> :ets.match(continuation) end, ets.creator)
    {:next, row, %ETS{ets | match_state: match_state}}
  end

  def ets_retry(fun, nil = _creator) do
    fun.()
  end

  def ets_retry(fun, {m, f, a} = _creator) do
    try do
      fun.()
    rescue
      ArgumentError ->
        apply(m, f, a)
        fun.()
    end
  end
end

defimpl Enumerable, for: BubbleLib.MapUtil.AutoMap.ETS do
  import BubbleLib.MapUtil.AutoMap.ETS, only: [ets_retry: 2]

  alias BubbleLib.MapUtil.AutoMap.ETS

  def count(%ETS{}) do
    {:error, __MODULE__}
  end

  def member?(%ETS{table: table} = ets, elem) do
    {:ok, ets_retry(fn -> :ets.match(table, {:_, elem}) end, ets.creator) !== []}
  end

  def reduce(%ETS{table: table, match_state: nil} = ets, acc, fun) do
    match_state = ets_retry(fn -> :ets.match(table, :"$1", 1) end, ets.creator)
    reduce(%ETS{ets | match_state: match_state}, acc, fun)
  end

  def reduce(_list, {:halt, acc}, _fun), do: {:halted, acc}
  def reduce(list, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(list, &1, fun)}

  def reduce(%ETS{match_state: :"$end_of_table"}, {:cont, acc}, _fun) do
    {:done, acc}
  end

  def reduce(%ETS{match_state: {[[{_index, row}]], continuation}} = ets, {:cont, acc}, fun) do
    match_state = ets_retry(fn -> :ets.match(continuation) end, ets.creator)
    reduce(%ETS{ets | match_state: match_state}, fun.(row, acc), fun)
  end

  def slice(_) do
    {:error, __MODULE__}
  end
end

defimpl Poison.Encoder, for: BubbleLib.MapUtil.AutoMap.ETS do
  def encode(_ets, _options) do
    "\"#data\""
  end
end
