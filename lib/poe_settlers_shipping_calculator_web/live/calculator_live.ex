defmodule PoeSettlersShippingCalculatorWeb.CalculatorLive do
  use PoeSettlersShippingCalculatorWeb, :live_view

  def mount(_params, _session, socket) do
    fields = %{"resources_requested" => 0, "resources_sent" => 0, "resources_bonus" => 0}
    {:ok, assign(socket,
      resources_to_send: 0,
      error: nil,
      form: to_form(fields),
      form_two: to_form(fields)
      )}
  end
  def handle_event("calculate", %{"resources_requested" => resources_requested, "resources_sent" => resources_sent, "resources_bonus" => resources_bonus, "bars" => bars} = _params, socket) do
    # Clear the error message before performing a new calculation
    socket = assign(socket, :error, nil)
    multiplier = if bars == "true", do: 5, else: 1

    case calculate_resources_to_send(resources_requested, resources_sent, resources_bonus, multiplier) do
      {:ok, resources_to_send} ->
        # Assign the numerical value directly, which is safe to render
        socket = assign(socket, :resources_to_send, resources_to_send)
        {:noreply, socket}
      {:error, reason} ->
        # Assign the error reason as a string, which is also safe to render
        socket = assign(socket, :error, reason)
        # Optionally, clear the resources_to_send if you want to remove the previous successful message
        socket = assign(socket, :resources_to_send, nil)
        {:noreply, socket}
    end
  end

  def calculate_resources_to_send(resource_requested, resources_sent, resources_bonus, multiplier \\ 5) do
    case {Integer.parse(resource_requested), Integer.parse(resources_sent), Integer.parse(resources_bonus)} do
      {{resource_requested_int, ""}, {resources_sent_int, ""}, {resources_bonus_int, ""}} ->
        difference = resource_requested_int - resources_sent_int
        if difference > 0 do
          # Adjusted calculation: difference divided by 5, then adjusted for bonus
        divided_amount = difference / multiplier
          # Adjust for a 50% bonus by dividing by 1.5 (equivalent to multiplying by 2/3)
          adjusted_for_bonus = divided_amount / (1 + resources_bonus_int / 100.0)
          # Ensure the total resources to send is not less than zero
          resources_to_send = trunc(adjusted_for_bonus)
          resources_to_send = max(resources_to_send, 0)
          {:ok, resources_to_send}
        else
          {:error, "No additional resources need to be sent."}
        end
      _ ->
        {:error, "Invalid input. Please ensure all inputs are numeric."}
    end
  end
end
