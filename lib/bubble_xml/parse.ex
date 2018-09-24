defmodule BubbleXml.Parse do
  use BubbleXml.XmerlRecords
  import BubbleXml.Xmerl, only: [to_xmerl: 1]

  def xml_parse(xml_string) when is_binary(xml_string) do
    xml_string
    |> to_xmerl()
    |> xmerl_element()
  end

  def xmerl_element(xmlText(value: value)) do
    case IO.chardata_to_string(value) |> String.trim() do
      "" -> :skip
      text -> text
    end
  end

  def xmerl_element(xmlElement(name: name, attributes: attributes, content: content)) do
    [to_string(name), xmerl_attributes(attributes), xmerl_content(content)]
  end

  def xmerl_attributes(attributes) do
    attributes
    |> Enum.map(fn xmlAttribute(name: name, value: value) ->
      {to_string(name), to_string(value)}
    end)
    |> Map.new()
  end

  def xmerl_content([xmlText(value: _value) = elem]) do
    xmerl_element(elem)
  end

  def xmerl_content(children) do
    children
    |> Enum.reduce([], fn child, acc ->
      case xmerl_element(child) do
        :skip -> acc
        result -> [result | acc]
      end
    end)
    |> Enum.reverse()
  end
end
