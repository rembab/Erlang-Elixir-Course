import Config

config :pollution_db, PollutionDb.Repo,
  database: "pollution_db_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :pollution_db, PollutionDb.Repo,
  database: "pollution_db_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :pollution_db, Pollutiondb.Repo,
  database: "pollution_db_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"
config :pollutiondb, ecto_repos: [PollutionDb.Repo]  
config :pollutiondb, PollutionDb.Repo, database: "database/pollutiondb.db"
