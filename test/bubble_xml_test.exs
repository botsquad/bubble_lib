defmodule BubbleXmlTest do
  use ExUnit.Case

  test "xml_build delegate" do
    assert "<foo/>" == BubbleXml.xml_build(["foo", %{}, []])
  end

  test "xml_parse delegate" do
    assert ["foo", %{}, []] == BubbleXml.xml_parse("<foo/>")
  end

  test "xml_xpath delegate" do
    assert "bas" = BubbleXml.xml_xpath("<foo><bar>bas</bar></foo>", "/foo/bar/text()")
  end
end
