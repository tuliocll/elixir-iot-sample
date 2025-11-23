defmodule RaspdemoServer.Repo do
  use Ecto.Repo,
    otp_app: :raspdemo_server,
    adapter: Ecto.Adapters.SQLite3
end
