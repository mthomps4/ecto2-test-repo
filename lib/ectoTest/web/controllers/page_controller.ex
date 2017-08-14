defmodule EctoTest.Web.PageController do
  use EctoTest.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
