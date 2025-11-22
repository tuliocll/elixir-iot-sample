defmodule RaspDemo.Button do
  use GenServer
  alias Circuits.GPIO

  @pin 17

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(_opts) do
    {:ok, gpio} = GPIO.open(@pin, :input, pull_mode: :pullup)
    :ok = GPIO.set_interrupts(gpio, :both)
    {:ok, %{gpio: gpio}}
  end

  @impl true
  def handle_info({:circuits_gpio, _pin, _ts, 0}, state) do
    RaspDemo.Edge.Connection.button_pressed()
    {:noreply, state}
  end

  @impl true
  def handle_info({:circuits_gpio, _pin, _ts, 1}, state) do
    IO.puts("Button Released")
    {:noreply, state}
  end
end
