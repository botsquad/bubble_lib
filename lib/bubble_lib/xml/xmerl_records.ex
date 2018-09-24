defmodule BubbleLib.XML.XmerlRecords do
  defmacro __using__(_) do
    quote do
      require Record

      Record.defrecord(
        :xmlAttribute,
        Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")
      )

      Record.defrecord(:xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl"))

      Record.defrecord(
        :xmlElement,
        Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
      )
    end
  end
end
