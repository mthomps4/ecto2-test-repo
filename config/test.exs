use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ectoTest, EctoTest.Web.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :ectoTest, EctoTest.Repo,
  adapter: Mongo.Ecto,
  database: "ectotest_test",
  hostname: "localhost"
