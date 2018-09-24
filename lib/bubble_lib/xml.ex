defmodule BubbleLib.XML do
  defdelegate xml_build(data), to: BubbleLib.XML.Build
  defdelegate xml_parse(data), to: BubbleLib.XML.Parse
  defdelegate xml_xpath(data, query), to: BubbleLib.XML.XPath
end
