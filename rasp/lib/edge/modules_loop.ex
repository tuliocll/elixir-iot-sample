defmodule RaspDemo.Edge.ModulesLoop do
  use GenServer

  @interval 500

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def init(state) do
    schedule()
    {:ok, state}
  end

  def handle_info(:tick, state) do
    temp =
      case RaspDemo.TemperatureSensor.read() do
        {:ok, t} -> t
        _ -> nil
      end

    light =
      case RaspDemo.Luminosity.read() do
        {:ok, t_us} -> t_us
        _ -> nil
      end

    if temp && light do
      IO.puts("📡 Sending data: Temp=#{temp}°C, Light=#{light}")
      RaspDemo.Edge.Connection.push_sensor(temp, light)
    end

    schedule()
    {:noreply, state}
  end

  defp schedule, do: Process.send_after(self(), :tick, @interval)
end
