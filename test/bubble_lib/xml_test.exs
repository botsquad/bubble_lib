defmodule BubbleLib.XMLTest do
  use ExUnit.Case

  test "xml_build delegate" do
    assert "<foo/>" == BubbleLib.XML.xml_build(["foo", %{}, []])
  end

  test "xml_parse delegate" do
    assert ["foo", %{}, []] == BubbleLib.XML.xml_parse("<foo/>")
  end

  test "xml_xpath delegate" do
    assert "bas" = BubbleLib.XML.xml_xpath_one("<foo><bar>bas</bar></foo>", "/foo/bar/text()")
    assert ["bas"] = BubbleLib.XML.xml_xpath_all("<foo><bar>bas</bar></foo>", "/foo/bar/text()")
  end
end
