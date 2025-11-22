# Incomplete, need to finish

defmodule RaspDemo.Ultrasonic do
  use GenServer
  alias Circuits.GPIO

  @trig_pin 13
  @echo_pin 15
  @period_ms 500
  @timeout_ms 80

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(_) do
    {:ok, trig} = GPIO.open(@trig_pin, :output)
    {:ok, echo} = GPIO.open(@echo_pin, :input)

    GPIO.write(trig, 0)
    :ok = GPIO.set_pull_mode(echo, :none)
    :ok = GPIO.set_interrupts(echo, :both)

    # agenda primeira medição
    Process.send_after(self(), :trigger, 200)

    {:ok, %{trig: trig, echo: echo, t_start_native: nil, timeout_ref: nil}}
  end

  @doc """
  Trigger de medição
  """
  @impl true
  def handle_info(:trigger, state) do
    pulse_10us(state.trig)

    # timeout caso a borda de descida nunca venha
    tref = Process.send_after(self(), :measure_timeout, @timeout_ms)
    {:noreply, %{state | t_start_native: nil, timeout_ref: tref}}
  end

  @doc """
  início do pulso
  """
  @impl true
  def handle_info({:circuits_gpio, _pin, ts, 1}, state) do
    {:noreply, %{state | t_start_native: ts}}
  end

  @doc """
  fim do pulso, calcula distância
  """
  @impl true
  def handle_info({:circuits_gpio, _pin, ts, 0}, %{t_start_native: nil} = state) do
    # ignorar descida espúria (não pegou a subida)
    {:noreply, state}
  end

  def handle_info({:circuits_gpio, _pin, t_end_native, 0}, state) do
    cancel_timeout(state.timeout_ref)

    t1_us = System.convert_time_unit(state.t_start_native, :native, :microsecond)
    t2_us = System.convert_time_unit(t_end_native, :native, :microsecond)
    dur_us = max(t2_us - t1_us, 0)

    # som ~0,0343 cm/µs, ida e volta, /2
    dist_cm = Float.round(dur_us * 0.0343 / 2.0, 2)

    IO.puts("Distance: #{dist_cm} cm (#{dur_us} µs)")

    # agenda próxima leitura
    Process.send_after(self(), :trigger, @period_ms)
    {:noreply, %{state | t_start_native: nil, timeout_ref: nil}}
  end

  # timeout (sem borda de descida dentro de @timeout_ms)
  @impl true
  def handle_info(:measure_timeout, state) do
    IO.puts("Timeout (fora de alcance / sem eco)")
    Process.send_after(self(), :trigger, @period_ms)
    {:noreply, %{state | t_start_native: nil, timeout_ref: nil}}
  end

  # --------- helpers ----------
  defp pulse_10us(trig) do
    GPIO.write(trig, 0)
    busy_us(2)
    GPIO.write(trig, 1)
    busy_us(10)
    GPIO.write(trig, 0)
  end

  defp busy_us(us) do
    t0 = System.monotonic_time(:microsecond)
    wait_until = t0 + us
    while_monotonic(wait_until)
  end

  defp while_monotonic(target) do
    if System.monotonic_time(:microsecond) < target, do: while_monotonic(target), else: :ok
  end

  defp cancel_timeout(nil), do: :ok

  defp cancel_timeout(ref) do
    try do
      Process.cancel_timer(ref)
      :ok
    catch
      _, _ -> :ok
    end
  end
end
