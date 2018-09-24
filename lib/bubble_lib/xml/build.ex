defmodule BubbleLib.XML.Build do
  import BubbleLib.MapUtil, only: [normalize: 1]
  import BubbleLib.XML.Xmerl, only: [xmerl_to_string: 1, to_xmerl: 1]

  def xml_build(data) do
    data
    |> normalize()
    |> to_xmerl()
    |> xmerl_to_string()
  end
end
