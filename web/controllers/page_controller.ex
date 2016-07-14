defmodule Thinker.PageController do
  use Thinker.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def tools(conn, _params) do
    render conn, "tools.html"
  end
end
