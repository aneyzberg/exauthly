defmodule Newline.V1.SessionController do
  use Newline.Web, :controller

  alias Newline.SessionView
  alias Newline.{UserService}

  # Login
  def create(conn, %{"email" => email, "password" => password} = _params) do
    case UserService.user_login(%{email: email, password: password}) do
      {:error, reason} -> 
        conn
        |> put_status(:unauthorized)
        |> render(SessionView, "401.json", message: reason)
      {:ok, user} ->
        conn
        |> Plug.Conn.assign(:current_user, user)
        |> put_status(:created)
        |> render(SessionView, "show.json", user_id: user.id, token: user.token)
    end
  end

  ## Logout
  def delete(conn, _) do
    {:ok, claims} = Guardian.Plug.claims(conn)

    conn
    |> Guardian.Plug.current_token
    |> Guardian.revoke!(claims)

    conn
    |> render(Newline.SessionView, "delete.json")
  end

end