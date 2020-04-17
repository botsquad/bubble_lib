defmodule BubbleLib.MapUtil.AutoMapTest do
  use ExUnit.Case

  defmodule Location do
    defstruct [:lat, :lon]
  end

  alias BubbleLib.MapUtil.AutoMap

  test "put in" do
    assert %{"a" => %{"b" => 123}} == AutoMap.put_in(%{}, [:a, :b], 123)
    assert %{"a" => %{"b" => 123}} == AutoMap.put_in(%{"a" => 1}, [:a, :b], 123)
    assert %{"a" => %{"b" => 1, "c" => 2}} == AutoMap.put_in(%{"a" => %{"b" => 1}}, [:a, :c], 2)

    assert %{"a" => %{}} == AutoMap.put_in(%{"a" => %{"b" => 1}}, [:a], %{})
    assert %{"a" => %{"c" => 2}} == AutoMap.put_in(%{"a" => %{"b" => 1}}, [:a], %{"c" => 2})
    assert %{"payload" => "aap"} == AutoMap.put_in(%{"payload" => %{"x" => 2}}, [:payload], "aap")
  end

  test "put in w/ array" do
    assert %{"a" => []} == AutoMap.put_in(%{"a" => [1, 2, 3]}, [:a], [])

    assert %{"a" => [123]} == AutoMap.put_in(%{}, [:a, 0], 123)
    # generates an array
    assert %{"a" => [nil, nil, 123]} == AutoMap.put_in(%{}, [:a, 2], 123)

    # update existing array
    assert %{"a" => [123]} == AutoMap.put_in(%{"a" => [0]}, [:a, 0], 123)
    assert %{"a" => [10, 123]} == AutoMap.put_in(%{"a" => [10, 0]}, [:a, 1], 123)
    assert %{"a" => [10, 123, 11]} == AutoMap.put_in(%{"a" => [10, 0, 11]}, [:a, 1], 123)

    # extend existing array
    assert %{"a" => [0, nil, 123]} == AutoMap.put_in(%{"a" => [0]}, [:a, 2], 123)
    assert %{"a" => [0, nil, nil, nil, 123]} == AutoMap.put_in(%{"a" => [0]}, [:a, 4], 123)

    # extend nested array
    assert [0, 1, [:a]] == AutoMap.put_in([0, 1, []], [2, 0], :a)
    assert [0, 1, [:x, :a]] == AutoMap.put_in([0, 1, [:x]], [2, 1], :a)
    assert [0, 1, [:x, :y, :a]] == AutoMap.put_in([0, 1, [:x, :y]], [2, 2], :a)

    assert [["x", ["y", "z"]]] == AutoMap.put_in([["x", ["y"]]], [0, 1, 1], "z")
    assert [["x", ["y", nil, "z"]]] == AutoMap.put_in([["x", ["y"]]], [0, 1, 2], "z")

    assert ["a", ["x", "bb", "z"]] == AutoMap.put_in(["a", ["x", "y", "z"]], [1, 1], "bb")

    assert [%{"lat" => 123, "x" => 2}] ==
             AutoMap.put_in([%{"x" => 2, "lat" => 1}], [0, "lat"], 123)
  end

  test "put_in w/ struct" do
    # invalid attr is ignored
    assert %Location{lat: 1} == AutoMap.put_in(%Location{lat: 1}, ["foo"], 34423)

    assert %Location{lat: 1} ==
             AutoMap.put_in(%Location{lat: 1}, ["asdf0s8df0ds8f08ds0fsd809fds"], 34423)

    # valid attributes are updated
    assert %Location{lat: 123} == AutoMap.put_in(%Location{lat: 1}, ["lat"], 123)
    assert %Location{lat: 123} == AutoMap.put_in(%Location{lat: 1}, [:lat], 123)

    # also nested
    assert %{"a" => %Location{lat: 123}} ==
             AutoMap.put_in(%{"a" => %Location{lat: 1}}, ["a", "lat"], 123)

    assert [%Location{lat: 123}] ==
             AutoMap.put_in([%Location{lat: 1}], [0, "lat"], 123)
  end

  test "get in" do
    assert nil == AutoMap.get_in(%{}, [:a, :b])
    assert 1 == AutoMap.get_in(%{"a" => 1}, [:a])
    assert 1 == AutoMap.get_in(%{"a" => 1}, ["a"])

    assert nil == AutoMap.get_in(%{"a" => 1}, ["a", "b"])
    assert nil == AutoMap.get_in(%{"a" => 1}, ["a", :b])

    assert %{"b" => 1} == AutoMap.get_in(%{"a" => %{"b" => 1}}, ["a"])
  end

  test "get_in traverses structs" do
    assert 1 == AutoMap.get_in(%{"a" => %Location{lat: 1}}, ["a", "lat"])
    assert 1 == AutoMap.get_in(%{"a" => %Location{lat: 1}}, ["a", :lat])
    assert nil == AutoMap.get_in(%{"a" => %Location{lat: 1}}, ["a", :lat, :x])
  end

  defmodule S do
    defstruct x: 1
    @behaviour Access

    @impl Access
    def fetch(s, "foo") do
      {:ok, "bar"}
    end
  end

  test "get_in uses Access.fetch on structs" do
    assert "bar" == AutoMap.get_in(%{"a" => %S{}}, ["a", "foo"])
  end

  test "get in traverses lists" do
    assert 1 == AutoMap.get_in(%{"a" => [1]}, [:a, 0])
    assert 123 == AutoMap.get_in(%{"a" => [1, 123]}, [:a, 1])

    assert nil == AutoMap.get_in(%{}, [:a, 0])
    assert nil == AutoMap.get_in(%{"a" => [1, 123]}, [:a, 100])
    assert nil == AutoMap.get_in(%{"a" => [1, 123]}, [:a, :foo])
  end

  test "get in w/ negative index" do
    assert 1 == AutoMap.get_in(%{"a" => [1]}, [:a, -1])
    assert 2 == AutoMap.get_in(%{"a" => [1, 2]}, [:a, -1])
    assert 2 == AutoMap.get_in(%{"a" => [1, 2, 3]}, [:a, -2])
  end

  test "remove" do
    assert %{"a" => %{"y" => 2}} == AutoMap.remove(%{"a" => %{"x" => 1, "y" => 2}}, ["a", "x"])
    assert %{"a" => [nil, 1]} == AutoMap.remove(%{"a" => [111, 1]}, ["a", 0])
  end

  test "remove collapse - map" do
    assert %{} == AutoMap.remove(%{"a" => %{"x" => 1}}, ["a", "x"])
    assert %{} == AutoMap.remove(%{"a" => %{"x" => %{"y" => 1}}}, ["a", "x"])
    assert %{} == AutoMap.remove(%{"a" => %{"x" => %{"y" => 1}}}, ["a", "x", "y"])
  end

  test "remove collapse - list" do
    assert %{} == AutoMap.remove(%{"a" => [1]}, ["a", 0])
    assert %{} == AutoMap.remove(%{"a" => %{"b" => [1]}}, ["a", "b", 0])
    assert %{2 => 3} == AutoMap.remove(%{"a" => %{"b" => [1]}, 2 => 3}, ["a", "b", 0])
  end

  test "get in - filter on list value" do
    data = %{"foo" => [%{"a" => 1}, %{"a" => 2}]}
    assert [%{"a" => 1}] = AutoMap.get_in(data, ["foo", [a: 1]])
  end

  test "get in - filter on map value" do
    data = %{"foo" => %{"a" => 1}}
    assert [1] = AutoMap.get_in(data, ["foo", [id: "a"]])

    data = %{"foo" => %{"a" => [1, 2, 3]}}
    assert 3 = AutoMap.get_in(data, ["foo", [id: "a"], 0, 2])
  end

  test "iterate" do
    values = [1, 2, 3]
    value = AutoMap.loop_start(values)
    assert {:next, 1, value} = AutoMap.loop_next(value)
    assert {:next, 2, value} = AutoMap.loop_next(value)
    assert {:next, 3, value} = AutoMap.loop_next(value)
    assert :stop = AutoMap.loop_next(value)
  end
end
