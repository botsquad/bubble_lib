defmodule BubbleXml.Parse do
  require Record

  Record.defrecord(
    :xmlAttribute,
    Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")
  )

  Record.defrecord(:xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl"))

  def xml_parse(xml_string) when is_binary(xml_string) do
    {doc, []} =
      xml_string
      |> :binary.bin_to_list()
      |> :xmerl_scan.string(quiet: true)

    doc
    |> xmerl_element()
  end

  defp xmerl_element(xmlText(value: value)) do
    case IO.chardata_to_string(value) |> String.trim() do
      "" -> :skip
      text -> text
    end
  end

  defp xmerl_element(xmlElement(name: name, attributes: attributes, content: content)) do
    [to_string(name), xmerl_attributes(attributes), xmerl_content(content)]
  end

  defp xmerl_attributes(attributes) do
    attributes
    |> Enum.map(fn xmlAttribute(name: name, value: value) ->
      {to_string(name), to_string(value)}
    end)
    |> Map.new()
  end

  defp xmerl_content([xmlText(value: _value) = elem]) do
    xmerl_element(elem)
  end

  defp xmerl_content(children) do
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
