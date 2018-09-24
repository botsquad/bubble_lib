defmodule BubbleLib.XML.XPath do
  import BubbleLib.XML.Xmerl, only: [to_xmerl: 1]
  import BubbleLib.XML.Parse

  def xml_xpath(doc, selector) do
    :xmerl_xpath.string(to_charlist(selector), to_xmerl(doc))
    |> maybe_list_simple_element()
  end

  defp maybe_list_simple_element(results) when is_list(results) do
    simple_content(results)
  end

  defp maybe_list_simple_element(result) do
    simple_element(result)
  end
end
