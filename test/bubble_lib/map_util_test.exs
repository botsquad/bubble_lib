defmodule BubbleLib.MapUtilTest do
  use ExUnit.Case

  defmodule Location do
    defstruct [:lat, :lon]
  end

  alias BubbleLib.MapUtil
  alias BubbleLib.MapUtil.AutoMap.ETS

  test "deatomize" do
    assert %{"a" => %{"lat" => 1, "lon" => 2}} ==
             MapUtil.deatomize(%{"a" => %Location{lat: 1, lon: 2}}) |> MapUtil.drop_nils()
  end

  test "enum_materialize" do
    a = %{"foo" => "bar"}
    ets = ETS.new([a])

    assert %{x: [a]} == MapUtil.enum_materialize(%{x: ets})
  end

  test "normalize" do
    a = %{:foo => "bar"}
    ets = ETS.new([a])

    assert %{"x" => [%{"foo" => "bar"}]} == MapUtil.normalize(%{x: ets, y: nil})
  end
end
