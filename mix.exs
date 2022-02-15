defmodule BubbleLib.MixProject do
  use Mix.Project

  def project do
    [
      app: :bubble_lib,
      version: File.read!("VERSION"),
      elixir: "~> 1.9",
      description: description(),
      package: package(),
      source_url: "https://github.com/botsquad/bubble_lib",
      homepage_url: "https://github.com/botsquad/bubble_lib",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :test,
      deps: deps()
    ]
  end

  defp description do
    "Collection of utility functions for Botsquad's BubbleScript."
  end

  defp package do
    %{
      files: ["lib", "mix.exs", "*.md", "LICENSE", "VERSION"],
      maintainers: ["Arjan Scherpenisse"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/botsquad/bubble_lib"}
    }
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :xmerl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.0"},
      {:match_engine, "~> 1.0"},
      {:html_entities, "~> 0.5"}
    ]
  end
end
