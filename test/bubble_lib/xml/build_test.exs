defmodule BubbleLib.XML.BuildTest do
  use ExUnit.Case

  import BubbleLib.XML.Build

  test "basic elements" do
    assert "<foo/>" == xml_build(["foo", nil, nil])
    assert "<foo/>" == xml_build([:foo, nil, nil])
  end

  test "attributes" do
    assert "<foo a=\"b\"/>" == xml_build(["foo", [a: "b"], nil])
    assert "<foo a=\"b\"/>" == xml_build(["foo", %{"a" => "b"}, nil])
  end

  test "child elements" do
    assert "<foo><bar/></foo>" == xml_build(["foo", nil, [["bar", nil, nil]]])

    assert "<foo><bar/><bar/></foo>" ==
             xml_build(["foo", nil, [["bar", nil, nil], ["bar", nil, nil]]])

    assert "<foo><bar>bas</bar><bar b=\"2\"/></foo>" ==
             xml_build(["foo", nil, [["bar", nil, "bas"], ["bar", [b: 2], nil]]])
  end

  test "escaping" do
    assert "<foo bar=\"&amp;&lt;>\">foo&amp;bar</foo>" ==
             xml_build(["foo", %{"bar" => "&<>"}, "foo&bar"])
  end
end
