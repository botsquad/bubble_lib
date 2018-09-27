defmodule BubbleLib.XML.XPath do
  import BubbleLib.XML.Xmerl, only: [to_xmerl: 1]
  import BubbleLib.XML.Parse

  defmodule SyntaxError do
    defexception message: "XPath syntax error"
  end

  @doc """
  Select a list of values or elements from the given XML using an XPath expression. Always returns a list.
  """
  def xml_xpath_all(doc, selector) do
    case xpath(doc, selector) do
      list when is_list(list) ->
        Enum.map(list, &simple_element/1)

      value ->
        [simple_element(value)]
    end
  end

  @doc """
  Select a single value or element from the given XML using an XPath
  expression. If the result of the expression is not exactly one
  single element, `nil` will be returned.
  """
  def xml_xpath_one(doc, selector) do
    case xpath(doc, selector) do
      [] -> nil
      [value] -> simple_element(value)
      list when is_list(list) -> nil
      value -> simple_element(value)
    end
  end

  defp xpath(doc, selector) do
    xmerl = to_xmerl(doc)

    try do
      :xmerl_xpath.string(to_charlist(selector), xmerl)
    rescue
      FunctionClauseError ->
        raise SyntaxError, selector

      MatchError ->
        raise SyntaxError, selector
    end
  end
end
