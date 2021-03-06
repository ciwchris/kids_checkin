defmodule KidsCheckin.Router do
  use KidsCheckin.Web, :router

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

  scope "/", KidsCheckin do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/combined", PageController, :combined
    get "/counts", PageController, :counts
  end

  scope "/api", KidsCheckin do
    pipe_through :api

    get "newcheckin", WebHookController, :index

    post "newcheckin", WebHookController, :index
  end
end
