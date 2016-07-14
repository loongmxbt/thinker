use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or you later on).
config :thinker, Thinker.Endpoint,
  secret_key_base: "h3QIae9lqsWTdY+Rwp9MZWnKi8JIMKSSjtTRQfGlhFTv0Y4s23Qyz9dBDm0xJiBW"

# Configure your database
config :thinker, Thinker.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "thinker_prod",
  pool_size: 20
