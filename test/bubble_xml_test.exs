defmodule BubbleXmlTest do
  use ExUnit.Case

  test "xml_build delegate" do
    assert "<foo/>" == BubbleXml.xml_build(["foo", %{}, []])
  end

  test "xml_parse delegate" do
    assert ["foo", %{}, []] == BubbleXml.xml_parse("<foo/>")
  end
end
