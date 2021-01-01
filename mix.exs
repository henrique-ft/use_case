defmodule UseCase.MixProject do
  use Mix.Project

  def project do
    [
      app: :use_case,
      version: "0.2.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description:
        "A way to increase Elixir projects readability and maintenance based on Use Cases and Interactors.",
      package: package(),
      docs: [logo: "priv/static/logo.png", extras: ["README.md"], main: "readme"],
      name: "UseCase",
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev, runtime: false}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "test"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      name: :use_case,
      maintainers: ["Henrique Fernandez Teixeira"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/henriquefernandez/use_case"}
    ]
  end
end
