defmodule BubbleLib.MapUtil.AutoMap do
  @moduledoc """
  Automagic map — creates deep elements inside. All map keys are
  coerced to strings except for list indexes.
  """

  alias BubbleLib.MapUtil.AutoMap
  alias BubbleLib.MapUtil.AutoMap.ETS

  import Kernel, except: [get_in: 2]

  def put_in(data, keys, value) do
    elem(kernel_get_and_update_in(data, keys, fn _ -> {nil, value} end), 1)
  end

  defp kernel_get_and_update_in(data, [head], fun) when is_function(head, 3),
    do: head.(:get_and_update, data, fun)

  defp kernel_get_and_update_in(data, [head | tail], fun) when is_function(head, 3),
    do: head.(:get_and_update, data, &kernel_get_and_update_in(&1, tail, fun))

  defp kernel_get_and_update_in(data, [head], fun) when is_function(fun, 1),
    do: access_get_and_update(data, head, fun)

  defp kernel_get_and_update_in(data, [head | tail], fun) when is_function(fun, 1),
    do: access_get_and_update(data, head, &kernel_get_and_update_in(&1, tail, fun))

  defp access_get_and_update(%{__struct__: _} = struct, key, fun) when is_binary(key) do
    try do
      key = String.to_existing_atom(key)

      case Map.fetch(struct, key) do
        {:ok, _} ->
          {nil, _value} = Map.get_and_update(struct, key, fun)

        :error ->
          {nil, struct}
      end
    rescue
      ArgumentError ->
        {nil, struct}
    end
  end

  defp access_get_and_update(map, key, fun) when is_map(map) and is_atom(key) do
    access_get_and_update(map, Atom.to_string(key), fun)
  end

  defp access_get_and_update(map, key, fun) when is_map(map) do
    {nil, _value} = Map.get_and_update(map, key, fun)
  end

  defp access_get_and_update(nil, key, fun) when is_integer(key) do
    {_, value} = fun.(nil)
    {nil, ensure_list(nil, key, value)}
  end

  defp access_get_and_update(list, key, fun) when is_list(list) and is_integer(key) do
    {_, value} = fun.(Enum.at(list, key))
    {nil, ensure_list(list, key, value)}
  end

  defp access_get_and_update(_any, key, fun) do
    m = AutoMap.put_in(%{}, [key], elem(fun.(nil), 1))
    {nil, m}
  end

  def get_in(%{} = map, [head | tail]) when is_atom(head) do
    get_in(map, [to_string(head) | tail])
  end

  def get_in(%ETS{} = struct, path) do
    ETS.get_in(struct, path)
  end

  def get_in(%{__struct__: _} = struct, [head | tail]) do
    try do
      value = Kernel.get_in(struct, [head])
      get_in(value, tail)
    rescue
      UndefinedFunctionError ->
        try do
          get_in(Map.get(struct, String.to_existing_atom(head), nil), tail)
        rescue
          ArgumentError ->
            nil
        end
    end
  end

  def get_in(list, [head | tail]) when is_list(list) and is_integer(head) do
    get_in(Enum.at(list, head), tail)
  end

  def get_in(list, [query | tail]) when is_list(list) and is_list(query) do
    get_in(MatchEngine.filter_all(list, query), tail)
  end

  def get_in(map, [[{:id, key}] | tail]) when is_map(map) do
    case Map.fetch(map, key) do
      {:ok, value} -> [value]
      :error -> []
    end
    |> get_in(tail)
  end

  def get_in(%{} = map, [head | tail]) do
    case Map.get(map, head, :undefined) do
      :undefined ->
        nil

      value ->
        get_in(value, tail)
    end
  end

  def get_in(value, []) do
    value
  end

  def get_in(_value, _rest) do
    nil
  end

  def loop_start(%ETS{} = struct) do
    ETS.loop_start(struct)
  end

  def loop_start(values) when is_list(values) do
    values
  end

  def loop_start(_) do
    :unsupported
  end

  def loop_next([head | tail]) do
    {:next, head, tail}
  end

  def loop_next([]) do
    :stop
  end

  def loop_next(%ETS{} = struct) do
    ETS.loop_next(struct)
  end

  def loop_next(:unsupported) do
    :stop
  end

  defp ensure_list(list, index, value) when index < 0 do
    ensure_list(list, index + length(list), value)
  end

  defp ensure_list(nil, 0, value) do
    [value]
  end

  defp ensure_list(nil, max_index, value) when max_index > 0 do
    0..max_index
    |> Enum.map(fn
      ^max_index -> value
      _ -> nil
    end)
  end

  defp ensure_list(list, index, value) when is_list(list) do
    value = recombine_list(Enum.at(list, index), value)

    list =
      case length(list) > index do
        true ->
          list

        false ->
          list ++ (length(list)..index |> Enum.map(fn _ -> nil end))
      end

    list
    |> Enum.zip(0..(length(list) - 1))
    |> Enum.map(fn
      {_, ^index} -> value
      {v, _} -> v
    end)
  end

  defp recombine_list(old, new) when is_list(new) and is_list(old) do
    list_indices(old, new)
    |> Enum.map(fn idx ->
      oldval = Enum.at(old, idx)
      newval = Enum.at(new, idx)
      recombine_list(oldval, newval)
    end)
  end

  defp recombine_list(old, new) do
    new || old
  end

  defp list_indices(a, b) do
    0..(max(length(a), length(b)) - 1)
  end

  def remove(map, []) do
    map
  end

  def remove(list, [index]) when is_list(list) and is_integer(index) do
    List.delete_at(list, index)
  end

  def remove(%{} = map, [key]) do
    Map.delete(map, key)
  end

  def remove(%{} = map, [key | tail]) do
    if Map.has_key?(map, key) do
      value = remove(Map.get(map, key), tail)

      case empty(value) do
        true ->
          Map.delete(map, key)

        false ->
          Map.put(map, key, value)
      end
    else
      map
    end
  end

  def remove(list, [index | tail]) when is_list(list) and is_integer(index) do
    value = remove(Enum.at(list, index), tail)

    case empty(value) do
      true ->
        List.delete_at(list, index)

      false ->
        List.replace_at(list, index, value)
    end
  end

  defp empty([]), do: true

  defp empty(m) when is_list(m) do
    Enum.reduce(m, true, fn v, acc -> acc and v == nil end)
  end

  defp empty(m), do: m == %{}
end
