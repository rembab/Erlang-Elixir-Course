defmodule PollutionDb.Repo do
  use Ecto.Repo,
    otp_app: :pollution_db,
    adapter: Ecto.Adapters.Postgres
end
