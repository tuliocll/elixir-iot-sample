defmodule RaspDemo.MixProject do
  use Mix.Project

  def project do
    [
      app: :rasp_demo,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto, :ssl, :inets],
      mod: {RaspDemo.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:circuits_gpio, "~> 2.1"},
      {:phoenix_client, "~> 0.11.1"},
      {:jason, "~> 1.4"},
      {:websocket_client, "~> 1.4"}
    ]
  end
end
