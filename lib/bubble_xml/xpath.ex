defmodule BubbleXml.XPath do
  import BubbleXml.Xmerl, only: [to_xmerl: 1]
  import BubbleXml.Parse

  def xml_xpath(doc, selector) do
    :xmerl_xpath.string(to_charlist(selector), to_xmerl(doc))
    |> maybe_list_xmerl_element()
  end

  defp maybe_list_xmerl_element(results) when is_list(results) do
    xmerl_content(results)
  end

  defp maybe_list_xmerl_element(result) do
    xmerl_element(result)
  end
end
