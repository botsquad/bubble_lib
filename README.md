# BubbleLib

[![Build Status](https://travis-ci.org/botsquad/bubble_lib.svg?branch=master)](https://travis-ci.org/botsquad/bubble_lib)

Generic collection of utility functions for BubbleScript.

* `BubbleLib.XML` — XML handling (parse / build / query), using `:xmerl`
* `BubbleLib.Builtins` — easy to use builtin functions and "loose" operators
* `BubbleLib.AutoMap` — "Easy" lossy / auto maps / array access
* `%BubbleLib.AutoMap.ETS{}` for storing large collections in AutoMap


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `bubble_xml` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bubble_xml, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/bubble_xml](https://hexdocs.pm/bubble_xml).
