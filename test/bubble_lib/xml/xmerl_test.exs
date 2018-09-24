defmodule BubbleLib.XML.XmerlTest do
  use ExUnit.Case
  import BubbleLib.XML.Xmerl

  test "to xmerl" do
    assert xmlElement(name: :a) = to_xmerl(["a", nil, nil])
  end
end
