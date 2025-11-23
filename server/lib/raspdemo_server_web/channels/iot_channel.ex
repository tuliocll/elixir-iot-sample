defmodule RaspdemoServerWeb.IotChannel do
  use RaspdemoServerWeb, :channel
  alias RaspdemoServerWeb.Helpers.Formatter

  @impl true
  def join("iot:lobby", payload, socket) do
    {:ok, socket}
  end

  def handle_in("sensor_update", %{"temp" => temp, "light" => light}, socket) do
    light_formatted = %{
      percent: Formatter.normalize_light(light),
      label:
        Formatter.normalize_light(light)
        |> Formatter.classify_light()
    }

    broadcast_from!(socket, "sensor_update", %{
      temp: :erlang.float_to_binary(temp, decimals: 2),
      light: light_formatted
    })

    {:noreply, socket}
  end

  def handle_in("button_pressed", _payload, socket) do
    broadcast_from!(socket, "button_pressed", %{})

    {:noreply, socket}
  end
end
