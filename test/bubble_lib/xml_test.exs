defmodule BubbleLib.XMLTest do
  use ExUnit.Case

  import BubbleLib.XML

  test "xml_build delegate" do
    assert "<foo/>" == xml_build(["foo", %{}, []])
  end

  test "xml_parse delegate" do
    assert ["foo", %{}, []] == xml_parse("<foo/>")
  end

  test "xml_xpath delegate" do
    assert "bas" = xml_xpath_one("<foo><bar>bas</bar></foo>", "/foo/bar/text()")
    assert ["bas"] = xml_xpath_all("<foo><bar>bas</bar></foo>", "/foo/bar/text()")
  end

  test "xml_build / xml_parse keep encoding" do
    xml = "<tag>lalala née öááaäöë!!™©</tag>"
    assert xml == xml_build(xml_parse(xml))
  end
end
