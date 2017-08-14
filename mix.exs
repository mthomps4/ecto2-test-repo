defmodule EctoTest.Mixfile do
  use Mix.Project

  def project do
    [app: :ectoTest,
     version: "0.0.1",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {EctoTest.Application, []},
     extra_applications: [
        :ecto,
        :mongodb,
        :runtime_tools,
        :logger,
        :poolboy,
        :uuid,
        :absinthe_plug,
        :absinthe_relay,
        :timex
       ]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
    {:phoenix, "~> 1.3.0-rc"},
    {:phoenix_pubsub, "~> 1.0"},
    {:phoenix_html, "~> 2.6"},
    {:phoenix_live_reload, "~> 1.0", only: :dev},
    {:percept, github: 'erlang/percept'},
    {:mix_test_watch, "~> 0.4", only: :dev, runtime: false},
    {:poolboy, ">= 0.0.0"},
    # the mongodb_ecto & phoenix_ecto, both need to require same {:ecto, "~> 2.0"}
    #--REVERTED-- {:phoenix_ecto, "~> 3.2"},
    #  --NOTREADY-- {:mongodb_ecto, github: "michalmuskala/mongodb_ecto", branch: "ecto-2.1"},
    {:phoenix_ecto, github: "phoenixframework/phoenix_ecto", ref: "v3.0.1"},
    {:mongodb_ecto, github: "michalmuskala/mongodb_ecto", branch: "ecto-2"},
    {:ecto, "~> 2.0.0", override: true},
    {:ex_doc, "~> 0.16.1"},
    {:ecto_enum, "~> 1.0"},
    {:distillery, "~> 1.4", runtime: false},
    {:gettext, "~> 0.11"},
    {:cowboy, "~> 1.0"},
    # Poision 3.+ flags older phoenix ecto -- no breaking changes override:true
    {:poison, "~> 3.1", override: true},
    {:uuid, "~> 1.1" },
    {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
    {:absinthe, "~> 1.3"},
    {:absinthe_relay, "~> 1.3.0"},
    {:absinthe_ecto, git: "https://github.com/absinthe-graphql/absinthe_ecto.git"},
    {:absinthe_plug, "~>1.3"},
    {:cors_plug, "~> 1.2"},
    {:timex, "~> 3.1"},
    {:coverex, "== 1.4.10", only: :test},
    {:ex_machina, "~> 2.0", only: :test},
   ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
