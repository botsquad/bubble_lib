defmodule BubbleLib.MapUtil do
  @moduledoc """
  Map utility functions
  """

  alias BubbleLib.MapUtil.AutoMap.ETS

  def normalize(value) do
    value
    |> deep_keyword_to_map()
    |> enum_materialize()
    |> deatomize()
    |> drop_nils()
  end

  def deatomize(%mod{} = struct) do
    struct
    |> Map.from_struct()
    |> Enum.reduce(struct, fn
      {k, v}, acc when is_map(v) or is_list(v) -> Map.put(acc, k, deatomize(v))
      {k, v}, acc -> Map.put(acc, k, v)
    end)
    |> Map.put(:__struct__, mod)
  end

  def deatomize(%{} = map) do
    Map.new(map, fn
      {%_{} = k, v} -> {k, deatomize(v)}
      {k, v} when is_atom(k) and (is_map(v) or is_list(v)) -> {Atom.to_string(k), deatomize(v)}
      {k, v} when is_map(v) or is_list(v) -> {k, deatomize(v)}
      {k, v} when is_atom(k) -> {Atom.to_string(k), v}
      {k, v} -> {k, v}
    end)
  end

  def deatomize(list) when is_list(list) do
    list
    |> Enum.map(&deatomize/1)
  end

  def deatomize(value) do
    value
  end

  def drop_nils(%{__struct__: _} = struct) do
    struct
    |> Map.delete(:__struct__)
    |> drop_nils()
  end

  def drop_nils(%{} = map) do
    map
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.map(fn {k, v} -> {k, drop_nils(v)} end)
    |> Enum.into(%{})
  end

  def drop_nils(list) when is_list(list) do
    list
    |> Enum.map(&drop_nils/1)
  end

  def drop_nils(value) do
    value
  end

  def deep_keyword_to_map(%{__struct__: _} = value) do
    value
  end

  def deep_keyword_to_map(value) when is_map(value) do
    Map.new(value, fn {k, v} -> {k, deep_keyword_to_map(v)} end)
  end

  def deep_keyword_to_map([{_, _} | _] = value) do
    Map.new(value, fn {k, v} -> {k, deep_keyword_to_map(v)} end)
  end

  def deep_keyword_to_map(value) when is_list(value) do
    Enum.map(value, fn v -> deep_keyword_to_map(v) end)
  end

  def deep_keyword_to_map(value), do: value

  def enum_materialize(%ETS{} = value) do
    Enum.to_list(value)
  end

  def enum_materialize(%{__struct__: _} = value) do
    value
  end

  def enum_materialize(%{} = map) do
    Map.new(map, fn {k, v} -> {k, enum_materialize(v)} end)
  end

  def enum_materialize(list) when is_list(list) do
    list
    |> Enum.map(&enum_materialize/1)
  end

  def enum_materialize(value) do
    value
  end

  @doc """
  Recursively run a mapper function on the 'leaf nodes' of the given nested term.

  Leaf nodes are any term that are not a list or a map. Tuples and structs are
  also considered leaf nodes!
  """
  @spec map_leafs(term(), (term() -> term())) :: term()
  def map_leafs(value, mapper)

  def map_leafs(%{__struct__: _} = value, mapper) do
    mapper.(value)
  end

  def map_leafs(%{} = map, mapper) do
    Map.new(Enum.map(map, fn {k, v} -> {k, map_leafs(v, mapper)} end))
  end

  def map_leafs([], _mapper), do: []

  def map_leafs([_ | _] = list, mapper) do
    Enum.map(list, &map_leafs(&1, mapper))
  end

  def map_leafs(value, mapper) do
    mapper.(value)
  end
end
