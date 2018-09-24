defmodule BubbleXml.Build do
  import Bubble.MapUtil, only: [normalize: 1]

  def xml_build(data) do
    data
    |> normalize()
    |> element()
    |> XmlBuilder.generate(format: :none)
  end

  defp element([name, attr, children]) do
    {name, attr, sub_elements(children)}
  end

  defp sub_elements(nil), do: nil

  defp sub_elements([elem, _, _] = child) when is_binary(elem) do
    sub_elements([child])
  end

  defp sub_elements(children) when is_binary(children) do
    children
  end

  defp sub_elements(list) when is_list(list) do
    list |> Enum.map(&element/1)
  end
end
