defmodule RaspDemo.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      {RaspDemo.Edge.Connection, []},
      {RaspDemo.Button, []},
      {RaspDemo.Edge.ModulesLoop, []}
      # {RaspDemo.Ultrasonic, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: RaspDemo.Supervisor)
  end
end
