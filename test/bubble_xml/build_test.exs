defmodule BubbleXml.BuildTest do
  use ExUnit.Case

  import BubbleXml.Build

  test "basic elements" do
    assert "<foo/>" == build_xml(["foo", nil, nil])
    assert "<foo/>" == build_xml([:foo, nil, nil])
  end

  test "attributes" do
    assert "<foo a=\"b\"/>" == build_xml(["foo", [a: "b"], nil])
    assert "<foo a=\"b\"/>" == build_xml(["foo", %{"a" => "b"}, nil])
  end

  test "child elements" do
    assert "<foo><bar/></foo>" == build_xml(["foo", nil, ["bar", nil, nil]])

    assert "<foo><bar/><bar/></foo>" ==
             build_xml(["foo", nil, [["bar", nil, nil], ["bar", nil, nil]]])

    assert "<foo><bar>bas</bar><bar b=\"2\"/></foo>" ==
             build_xml(["foo", nil, [["bar", nil, "bas"], ["bar", [b: 2], nil]]])
  end
end
