defmodule BubbleLib.XML do
  @moduledoc """
  XML functions

  XML is represented in Bubblescript as a nested array.

  XML is an inherently more difficult datatype to work with than JSON,
  as XML an XML element has different notions of data: the XML's
  attribute name, its attributes, and a list of its children.

  An XML element like this:

      <element attr="val">content</element>

  Will be represented as an array with three elements:

      ["element", %{"attr" => "val"}, "content"]

  The first element of this array is always the element's name; the
  second are its attributes, and the third is its contents. When the
  XML element contains children, the elemen's contents will be an
  array of new XML elements (again represented of 3-element arrays).
  """

  @doc """
  Build an XML string out of a data structure.

      iex> xml_build(["element", %{"attr" => "val"}, "content"])
      "<element attr=\"val\">content</element>"

  """
  defdelegate xml_build(data), to: BubbleLib.XML.Build

  @doc """
  Parse an XML string into a data structure.

      iex> xml_parse("<element attr=\"val\">content</element>")
      ["element", %{"attr" => "val"}, "content"]

  """
  defdelegate xml_parse(data), to: BubbleLib.XML.Parse

  @doc """
  Select a single value or XML element

  Selects a single value or XML from the given XML data structure
  using an XPath expression. If the result of the expression is not
  exactly one single element, `nil` will be returned.
  """
  defdelegate xml_xpath_one(data, query), to: BubbleLib.XML.XPath

  @doc """
  Select a list of values or XML elements

  Selects a list of values or XML elements from the given XML using an
  XPath expression. Always returns a list. In the case that no
  elements were selected, an empty list is returned.
  """
  defdelegate xml_xpath_all(data, query), to: BubbleLib.XML.XPath
end
