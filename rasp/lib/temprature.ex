defmodule RaspDemo.TemperatureSensor do
  @device_glob "/sys/bus/w1/devices/28-*"

  def read do
    with {:ok, path} <- find_device(),
         {:ok, content} <- File.read(path),
         {:ok, temp} <- parse(content) do
      {:ok, temp}
    else
      error -> error
    end
  end

  defp find_device do
    case Path.wildcard(@device_glob) do
      [dir | _] -> {:ok, Path.join(dir, "w1_slave")}
      [] -> {:error, :no_sensor_found}
    end
  end

  defp parse(content) do
    # get the second line, thats ends with "... t=23400"
    [_, line2] = String.split(content, "\n", trim: true)

    case String.split(line2, "t=") do
      [_, t_str] ->
        {micro_c, _} = Integer.parse(t_str)
        {:ok, micro_c / 1000.0}

      _ ->
        {:error, :bad_format}
    end
  end
end
