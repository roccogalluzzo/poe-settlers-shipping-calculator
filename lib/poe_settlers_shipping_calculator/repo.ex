defmodule PoeSettlersShippingCalculator.Repo do
  use Ecto.Repo,
    otp_app: :poe_settlers_shipping_calculator,
    adapter: Ecto.Adapters.Postgres
end
