defmodule BubbleLib.XML.Xmerl do
  @moduledoc """
  Convert 'plain' tuple notation into full XMerl XML notation
  """
  use BubbleLib.XML.XmerlRecords

  def to_xmerl(content) when is_binary(content) do
    {doc, []} =
      content
      |> :erlang.binary_to_list()
      |> :xmerl_scan.string(quiet: true)

    doc
  end

  def to_xmerl([_, _, _] = content) do
    content
    |> xmerl_element()
  end

  defp xmerl_element(value) when is_binary(value) do
    xmlText(value: value)
  end

  defp xmerl_element([name, attributes, content]) do
    xmlElement(
      name: atomize(name),
      attributes: xmerl_attributes(attributes),
      content: xmerl_content(content)
    )
  end

  defp xmerl_attributes(nil), do: []

  defp xmerl_attributes(attributes) do
    attributes
    |> Enum.map(fn {key, value} ->
      xmlAttribute(name: atomize(key), value: to_string(value))
    end)
  end

  defp xmerl_content(nil), do: []

  defp xmerl_content(value) when is_binary(value) do
    [xmlText(value: value)]
  end

  defp xmerl_content(content) when is_list(content) do
    content
    |> Enum.map(&xmerl_element/1)
  end

  defmodule Export do
    def unquote({:"#xml-inheritance#", [], nil}), do: [:xmerl_xml]
    def unquote({:"#text#", [], [Macro.var(:text, nil)]}), do: HtmlEntities.encode(text)
  end

  def xmerl_to_string(e) do
    "<?xml version=\"1.0\"?>" <> xml = IO.chardata_to_string(:xmerl.export_simple([e], Export))

    xml
  end

  defp atomize(name) when is_atom(name), do: name
  defp atomize(name) when is_binary(name), do: String.to_atom(name)
end
