defmodule BubbleLib.MapUtilTest do
  use ExUnit.Case

  defmodule Location do
    defstruct [:lat, :lon, :data]
  end

  import BubbleLib.MapUtil
  alias BubbleLib.MapUtil.AutoMap.ETS

  test "deatomize" do
    assert [%{"a" => %{"b" => :c}}] == deatomize([%{a: %{b: :c}}])
  end

  test "deatomize retains structs" do
    assert [%{"a" => %Location{lat: 1, lon: 2}}] ==
             deatomize([%{a: %Location{lat: 1, lon: 2}}])
  end

  test "deatomize retains structs but deatomizes its contents" do
    assert [%{"a" => %Location{lat: 1, lon: 2, data: %{"b" => :c}}}] ==
             deatomize([%{a: %Location{lat: 1, lon: 2, data: %{b: :c}}}])
  end

  test "deatomize retains structs in map keys" do
    assert [%{%Location{lat: 1, lon: 2, data: %{b: :c}} => :a}] ==
             deatomize([%{%Location{lat: 1, lon: 2, data: %{b: :c}} => :a}])
  end

  test "enum_materialize" do
    a = %{"foo" => "bar"}
    ets = ETS.new([a])

    assert %{x: [a]} == enum_materialize(%{x: ets})

    l = %Location{}
    assert %{x: ^l} = enum_materialize(%{x: l})
  end

  test "normalize" do
    a = %{:foo => "bar"}
    ets = ETS.new([a])

    assert %{"x" => [%{"foo" => "bar"}]} == normalize(%{x: ets, y: nil})
  end

  describe "map_leafs" do
    defp test_map_leaf(pairs, mapper) do
      for {input, expected} <- pairs do
        assert expected == map_leafs(input, mapper)
      end
    end

    defmodule S do
      defstruct x: nil
    end

    test "map_leafs" do
      test_map_leaf(
        [
          {1, 2},
          {[1], [2]},
          {%{a: 1}, %{a: 2}},
          {%{:a => 1, "b" => 4}, %{:a => 2, "b" => 5}},
          {%{a: [1]}, %{a: [2]}},
          {[%{a: 1}], [%{a: 2}]},
          {[%S{}], [:struct]},
          {{1}, {1}}
        ],
        &mapper/1
      )
    end

    defp mapper(n) when is_integer(n), do: n + 1
    defp mapper(%{__struct__: _}), do: :struct
    defp mapper(t) when is_tuple(t), do: t
  end
end
