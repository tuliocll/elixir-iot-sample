defmodule RaspdemoServerWeb.PageController do
  use RaspdemoServerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
