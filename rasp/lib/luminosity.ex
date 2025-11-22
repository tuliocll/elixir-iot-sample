defmodule RaspDemo.Luminosity do
  @moduledoc """
  LDR Read using RC timing on a Raspberry Pi GPIO.
  """
  alias Circuits.GPIO

  @pin 22
  # time to discharge the capacitor
  @discharge_ms 50
  # timeout to avoid loop
  @timeout_us 1_000_000

  @doc """
  Returns {:ok, time_in_microseconds} or {:error, :timeout}.

  Lower time means less light.
  """
  def read do
    # 1) Open the pin as output and force 0V to discharge the capacitor
    {:ok, gpio} = GPIO.open(@pin, :output)
    GPIO.write(gpio, 0)
    Process.sleep(@discharge_ms)
    GPIO.close(gpio)

    # 2) Reopen the pin as input to let the capacitor charge
    {:ok, gpio} = GPIO.open(@pin, :input)

    t0 = System.monotonic_time(:microsecond)

    response =
      case wait_high(gpio, t0) do
        {:ok, delta} -> result = {:ok, delta}
        {:error, :timeout} -> result = {:error, :timeout}
      end

    GPIO.close(gpio)
    response
  end

  defp wait_high(gpio, t0) do
    case GPIO.read(gpio) do
      1 ->
        t1 = System.monotonic_time(:microsecond)
        {:ok, t1 - t0}

      0 ->
        now = System.monotonic_time(:microsecond)

        if now - t0 > @timeout_us do
          {:error, :timeout}
        else
          wait_high(gpio, t0)
        end
    end
  end
end
