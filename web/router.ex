defmodule Thinker.Router do
  use Thinker.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Thinker do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/tools", PageController, :tools
  end

  # Other scopes may use custom stacks.
  # scope "/api", Thinker do
  #   pipe_through :api
  # end
end
