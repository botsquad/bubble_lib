defmodule BubbleXml do
  @moduledoc """
  Documentation for BubbleXml.
  """

  defdelegate xml_build(data), to: BubbleXml.Build
end
