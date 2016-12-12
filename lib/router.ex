defmodule TrotCas.Router do
  alias Ueberauth.Strategy.CAS
  use Trot.Router

  @session Plug.Session.init(
    store: :cookie,
    key: "_app",
    encryption_salt: "09821psdfsdfosdfjspis0okm",
    signing_salt: "09821posasyuiyuI11jspisdas"
  )

  get "/" do
    conn = conn
             |> Map.put(:secret_key_base, String.duplicate("1qwGGnj8", 8))
             |> Plug.Session.call(@session)
             |> fetch_session

    case conn |> get_session(:user_id) do
      nil ->
        conn = conn |> CAS.add_conn_params! |> CAS.handle_callback!

        if Map.has_key?(conn.assigns, :ueberauth_failure) do
          case conn |> CAS.error_key do
            "missing_ticket" ->
              conn |> CAS.handle_request!
            _ ->
              "Fail login"
          end
        else
          conn
            |> put_session(:user_id, conn.private.cas_user.uid)
            |> put_session(:user_name, conn.private.cas_user.user)
            |> Plug.Conn.put_resp_header("location", "/")
            |> Plug.Conn.send_resp(307, "")
        end
      current_user_id ->
        "USER:#{get_session(conn,:user_name)};ID:#{current_user_id}" 
    end
  end

  get "/logout" do
    is_inner = CAS.API.inner_client?(conn)
    conn
      |> Map.put(:secret_key_base, String.duplicate("1qwGGnj8", 8))
      |> Plug.Session.call(@session)
      |> fetch_session
      |> clear_session
      |> Plug.Conn.put_resp_header("location", CAS.API.logout_url(is_inner))
      |> Plug.Conn.send_resp(307, "")
  end


  import_routes Trot.NotFound
end
