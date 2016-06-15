defmodule Mana.User.RegistrationCommand do
  use Mana.Web, :command
  alias Mana.User.Registration

  def prepare(registration_params \\ %{}) do
   Registration.changeset(%Registration{}, registration_params)
  end

  def run(registration_params \\ %{}) do
    changeset = Registration.changeset(%Registration{}, registration_params)
    case Repo.insert(changeset) do
      {:ok, registration} -> {:ok, Registration.to_user(registration)}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
