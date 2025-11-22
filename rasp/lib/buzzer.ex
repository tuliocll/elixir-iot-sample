defmodule RaspDemo.Buzzer do
  alias Circuits.GPIO

  @pin 23

  def beep(ms \\ 200) do
    {:ok, gpio} = GPIO.open(@pin, :output)

    GPIO.write(gpio, 0)
    Process.sleep(ms)

    GPIO.write(gpio, 1)
    GPIO.close(gpio)

    :ok
  end

  def mario do
    beep(100)
    Process.sleep(80)
    beep(150)
    Process.sleep(120)
    beep(80)
    Process.sleep(60)
    beep(200)
  end
end
