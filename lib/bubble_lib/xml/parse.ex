defmodule BubbleLib.XML.Parse do
  use BubbleLib.XML.XmerlRecords
  import BubbleLib.XML.Xmerl, only: [to_xmerl: 1]

  def xml_parse(xml_string) when is_binary(xml_string) do
    xml_string
    |> to_xmerl()
    |> simple_element()
  end

  def simple_element(xmlComment()) do
    :skip
  end

  def simple_element(xmlPI()) do
    :skip
  end

  def simple_element(xmlText(value: value)) do
    case IO.chardata_to_string(value) |> String.trim() do
      "" -> :skip
      text -> text
    end
  end

  def simple_element(xmlElement(name: name, attributes: attributes, content: content)) do
    [to_string(name), simple_attributes(attributes), simple_content(content)]
  end

  def simple_attributes(attributes) do
    attributes
    |> Enum.map(fn xmlAttribute(name: name, value: value) ->
      {to_string(name), to_string(value)}
    end)
    |> Map.new()
  end

  def simple_content([xmlText(value: _value) = elem]) do
    simple_element(elem)
  end

  def simple_content(children) do
    children
    |> Enum.reduce([], &simple_content_reducer/2)
    |> Enum.reverse()
  end

  defp simple_content_reducer([xmlText() = child], acc) do
    # xmerl weirdness: sometimes, a child element contains a nested list
    simple_content_reducer(child, acc)
  end

  defp simple_content_reducer(child, acc) do
    case simple_element(child) do
      :skip -> acc
      result -> [result | acc]
    end
  end
end
