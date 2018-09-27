defmodule BubbleLib.XML.XPath do
  import BubbleLib.XML.Xmerl, only: [to_xmerl: 1]
  import BubbleLib.XML.Parse

  defmodule SyntaxError do
    defexception message: "XPath syntax error"
  end

  @doc """
  Select values from the given XML using an XPath expression
  """
  def xml_xpath(doc, selector) do
    xmerl = to_xmerl(doc)

    result =
      try do
        :xmerl_xpath.string(to_charlist(selector), xmerl)
      rescue
        FunctionClauseError ->
          raise SyntaxError, selector

        MatchError ->
          raise SyntaxError, selector
      end

    result |> maybe_list_simple_element()
  end

  defp maybe_list_simple_element(results) when is_list(results) do
    simple_content(results)
  end

  defp maybe_list_simple_element(result) do
    simple_element(result)
  end
end
