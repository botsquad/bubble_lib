defmodule BubbleXml.MixProject do
  use Mix.Project

  def project do
    [
      app: :bubble_xml,
      version: File.read!("VERSION"),
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bubble, git: "git@gitlab.com:botsquad/bubble.git", branch: "master"},
      {:xml_builder, "~> 2.0.0"}
    ]
  end
end
