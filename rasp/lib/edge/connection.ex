defmodule RaspDemo.Edge.Connection do
  use GenServer

  alias PhoenixClient.{Socket, Channel, Message}

  @url "ws://192.168.0.15:4000/socket/websocket"

  def start_link(_opts),
    do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def init(state) do
    IO.puts("Starting websocket...")

    socket_opts = [
      url: @url
    ]

    {:ok, socket_pid} = PhoenixClient.Socket.start_link(socket_opts)

    # In Brasil we call this "gambiarra"
    Process.sleep(4000)

    {:ok, _, channel} = PhoenixClient.Channel.join(socket_pid, "iot:lobby")

    IO.inspect(channel, label: "Channel join result")

    {:ok, Map.put(state, :channel, channel)}
  end

  def push_sensor(temp, light) do
    GenServer.cast(__MODULE__, {:push_sensor, temp, light})
  end

  def button_pressed() do
    GenServer.cast(__MODULE__, :button_pressed)
  end

  def handle_cast({:push_sensor, temp, light}, %{channel: channel} = state) do
    payload = %{"temp" => temp, "light" => light}
    :ok = Channel.push_async(channel, "sensor_update", payload)
    {:noreply, state}
  end

  def handle_cast(:button_pressed, %{channel: channel} = state) do
    :ok = Channel.push_async(channel, "button_pressed", %{})
    {:noreply, state}
  end

  def handle_info(%Message{event: "buzzer_cmd", payload: payload}, state) do
    pattern = Map.get(payload, "pattern", "beep")

    case pattern do
      "mario" -> RaspDemo.Buzzer.mario()
      _ -> RaspDemo.Buzzer.beep()
    end

    {:noreply, state}
  end
end
