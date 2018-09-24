defmodule BubbleXml.XmerlTest do
  use ExUnit.Case
  import BubbleXml.Xmerl

  test "to xmerl" do
    assert xmlElement(name: :a) = to_xmerl(["a", nil, nil])
  end
end
