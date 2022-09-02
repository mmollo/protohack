defmodule Protohack.MixProject do
  use Mix.Project

  def project do
    [
      app: :protohack,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: true,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Protohack.Application, []}
    ]
  end

  defp deps do
    [
      {:thousand_island, "~> 0.5.9"},
      {:jason, "~> 1.3"},
      {:prime, "~> 0.1.1"}
    ]
  end
end
