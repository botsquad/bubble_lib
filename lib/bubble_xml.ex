defmodule BubbleXml do
  @moduledoc """
  Documentation for BubbleXml.
  """

  defdelegate xml_build(data), to: BubbleXml.Build
  defdelegate xml_parse(data), to: BubbleXml.Parse
end
