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

  test "enum_materialize" do
    a = %{"foo" => "bar"}
    ets = ETS.new([a])

    assert %{x: [a]} == enum_materialize(%{x: ets})
  end

  test "normalize" do
    a = %{:foo => "bar"}
    ets = ETS.new([a])

    assert %{"x" => [%{"foo" => "bar"}]} == normalize(%{x: ets, y: nil})
  end
end
