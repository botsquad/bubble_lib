defmodule BubbleLib.DslStructTest do
  use ExUnit.Case, async: true

  defmodule Test do
    use BubbleLib.DslStruct, x: nil, y: nil
  end

  require BubbleLib.DslStruct
  BubbleLib.DslStruct.jason_derive(Test)

  test "DSL struct" do
    a = %Test{x: 1}

    assert 1 == a[:x]
    assert 1 == a["x"]
  end

  test "can be accessed" do
    assert 2 = get_in(%Test{x: 2}, ["x"])
    assert 2 = get_in(%Test{x: 2}, [:x])
  end

  test "jason encode" do
    assert x = Jason.encode!(%Test{x: 2})
    assert "{\"__struct__\":" <> _ = x
  end

  test "jason encode + decode + instantiate" do
    assert x = Jason.encode!([%{"foo" => %Test{x: 2}}])

    value =
      Jason.decode!(x)
      |> BubbleLib.DslStruct.instantiate_structs()

    assert [%{"foo" => %Test{x: 2}}] = value

    # ensure we can doubly instantiate structs
    value |> BubbleLib.DslStruct.instantiate_structs()
  end
end
