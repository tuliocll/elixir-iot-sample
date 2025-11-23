defmodule RaspdemoServerWeb.Helpers.Formatter do
  @doc """
  Normalize a raw light sensor reading into a percentage (0-100%)
  the actual range may vary depending on the sensor and environment.
  """
  def normalize_light(raw) do
    min = 10_000
    max = 60_000

    raw =
      raw
      |> max(min)
      |> min(max)

    range = max - min

    percent =
      (max - raw)
      |> Kernel./(range)
      |> Kernel.*(100.0)

    Float.round(percent, 1)
  end

  def classify_light(percent) when percent < 10, do: "Very Dark"
  def classify_light(percent) when percent < 30, do: "Dark"
  def classify_light(percent) when percent < 60, do: "Dim"
  def classify_light(percent) when percent < 85, do: "Bright"
  def classify_light(_percent), do: "Very Bright"
end
