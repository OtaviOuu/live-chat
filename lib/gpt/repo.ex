defmodule Gpt.Repo do
  use Ecto.Repo,
    otp_app: :gpt,
    adapter: Ecto.Adapters.Postgres
end
