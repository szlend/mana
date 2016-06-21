defmodule Mana.Router do
  use Mana.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  scope "/", Mana do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/registrations", RegistrationController, only: [:new, :create]
    resources "/profile", ProfileController, only: [:edit, :update], singleton: true

    get "/auth/login", AuthController, :login
    post "/auth/login", AuthController, :login
  end

  # Other scopes may use custom stacks.
  # scope "/api", Mana do
  #   pipe_through :api
  # end
end
