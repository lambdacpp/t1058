defmodule T1058.Router do
  alias Ueberauth.Strategy.CAS
  use Trot.Router
  require Logger
  
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
        conn |> IO.inspect
        conn = conn |> CAS.add_conn_params!

        conn = if Map.has_key?(conn.params, "returnurl") do
          %Plug.Conn{params: %{"returnurl" => returnurl}} = conn
          Logger.info "Callback url :#{returnurl}"
          conn |> put_session(:app_url, returnurl)
        else
          conn 
        end |> CAS.handle_callback!

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
      _current_user_id ->
        url = case get_session(conn,:app_url) do
                nil -> Application.get_env(:t1058, :app_url)
                app_url -> "http://"<>app_url
              end
        conn
          |> Plug.Conn.put_resp_header("location",url)
          |> Plug.Conn.send_resp(307, "")
    end
  end

  get "/user" do
    user =  conn
    |> Map.put(:secret_key_base, String.duplicate("1qwGGnj8", 8))
    |> Plug.Session.call(@session)
    |> fetch_session
    |> get_session(:user_name)
    
    body =
    if is_nil user do
      "unauthorized"
    else
      case T1058.User.query user do
        nil ->
          "#{user} logined, but get user info fail"
        json ->
          json
      end
    end
    {200,body, [{"access-control-allow-origin", "*"},
                {"access-control-request-headers", "x-custom-header"}]}
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

  post "/" do
    Logger.info "User Logout"
  end

  import_routes Trot.NotFound
end
