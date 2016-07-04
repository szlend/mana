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

  pipeline :authenticated do
    plug Guardian.Plug.EnsureAuthenticated, handler: Mana.AuthErrorHandler
  end

  pipeline :not_authenticated do
    plug Guardian.Plug.EnsureNotAuthenticated, handler: Mana.AuthErrorHandler
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  scope "/", Mana do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/", Mana do
    pipe_through [:browser, :authenticated]

    get "/sign_out", SessionController, :delete

    resources "/profile", ProfileController, only: [:edit, :update], singleton: true
    resources "/games", GameController, only: [:index, :show, :new, :create]
  end

  scope "/", Mana do
    pipe_through [:browser, :not_authenticated]

    get "/sign_up", RegistrationController, :new
    post "/sign_up", RegistrationController, :create
    get "/sign_in", SessionController, :new
    post "/sign_in", SessionController, :create
  end
end
