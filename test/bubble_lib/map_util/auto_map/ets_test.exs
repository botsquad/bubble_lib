defmodule BubbleLib.MapUtil.AutoMap.ETSTest do
  use ExUnit.Case

  alias BubbleLib.MapUtil.AutoMap.ETS
  alias BubbleLib.MapUtil.AutoMap

  test "reset" do
    ets = ETS.new([%{"foo" => "bar"}])
    assert [_] = :ets.tab2list(ets.table)

    ets = ETS.reset(ets, [%{a: 1}, %{b: 2}])
    assert [_, _] = :ets.tab2list(ets.table)
  end

  test "get in" do
    ets = ETS.new([%{"foo" => "bar"}])

    assert nil == AutoMap.get_in(ets, ["blasdfsdfds"])
    assert nil == AutoMap.get_in(ets, [123_213])
    assert "bar" == AutoMap.get_in(ets, [0, "foo"])
  end

  test "get in - filter" do
    ets = ETS.new([%{"a" => 1}, %{"a" => 2}])

    assert [%{"a" => 1}] = AutoMap.get_in(ets, [[a: 1]])
  end

  test "iterate" do
    row = %{"foo" => "bar"}
    row2 = %{"foof" => "barf"}
    ets = ETS.new([row, row2])
    state = AutoMap.loop_start(ets)
    assert {:next, ^row, state} = AutoMap.loop_next(state)
    assert {:next, ^row2, state} = AutoMap.loop_next(state)
    assert :stop = AutoMap.loop_next(state)
  end

  test "Enum" do
    row = %{"foo" => "bar"}
    row2 = %{"foof" => "barf"}
    ets = ETS.new([row, row2])
    assert 2 == Enum.count(ets)

    assert false == Enum.member?(ets, %{x: 1})
    assert true == Enum.member?(ets, row)
    assert true == Enum.member?(ets, row2)

    # filter
    assert [] == Enum.filter(ets, &(&1 == :a))
    assert [row] == Enum.filter(ets, &(&1["foo"] == "bar"))
    assert [row2] == Enum.filter(ets, &(&1["foof"] == "barf"))
  end

  test "Poison encode" do
    ets = ETS.new([%{"foo" => "bar"}])
    assert "\"#data\"" == Poison.encode!(ets)
  end

  @create_mfa {__MODULE__, :create, []}
  def create() do
    send(__MODULE__, :created)
    ETS.new([%{"foo" => "bar"}], name: :asdf, creator: @create_mfa)
  end

  test "ETS owner dies, but gets recreated" do
    Process.register(self(), __MODULE__)
    parent = self()

    spawn(fn ->
      ets = create()
      send(parent, {:ets, ets})
    end)

    # make sure creating process is dead.
    Process.sleep(20)

    assert_receive :created
    assert_receive {:ets, ets}

    assert 1 == Enum.count(ets)
    # a new ETS entry is created
    assert_receive :created
  end
end
