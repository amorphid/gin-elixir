defmodule Gin.MixProject do
  use Mix.Project

  #######
  # API #
  #######

  def application() do
    [
      extra_applications: [:logger],
      mod: {Gin.Application, []}
    ]
  end

  def project() do
    [
      app: :gin,
      deps: deps(),
      description: description(),
      elixir: "~> 1.8",
      package: package(),
      start_permanent: Mix.env() == :prod,
      version: "0.4.0",
    ]
  end

  ###########
  # Private #
  ###########

  defp deps() do
    [
      # Doc generator
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description() do
    "An Elixir wrapper for various Erlang gen modules"
  end

  defp package() do
    [
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/amorphid/gin-elixir"}
    ]
  end
end
