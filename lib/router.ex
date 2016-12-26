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
    Logger.debug "Remote IP:#{conn.remote_ip |> Tuple.to_list|> Enum.join(".") }"
    case conn |> get_session(:user_name) do
      nil ->
        param_map = query_string_to_map(conn.query_string)    

        session_map = param_map 
          |> Map.to_list
          |> Enum.filter( fn({x,_})-> x in ["returnurl","userkey"] end )
          |> Enum.map(fn ({x,y}) -> {String.to_atom(x),y} end )
        
        # 1 add paras 2 add cookie 3 callback
        conn = conn
          |> add_conn_params!(param_map)
          |> add_conn_session!(session_map)
          |> CAS.handle_callback!

        if Map.has_key?(conn.assigns, :ueberauth_failure) do
          case conn |> CAS.error_key do
            "missing_ticket" ->
              Logger.debug "#{conn.remote_ip |> Tuple.to_list|> Enum.join(".") } redirect to CAS Server."
              conn |> CAS.handle_request!
            _ ->
              Logger.debug "#{conn.remote_ip |> Tuple.to_list|> Enum.join(".")}  CAS Server auth fail."
              "Fail login"
          end
        else
          Logger.debug "#{conn.remote_ip |> Tuple.to_list|> Enum.join(".")} ticket used. user:#{conn.private.cas_user.user}"
          conn
            |> put_session(:user_name, conn.private.cas_user.user)
            |> put_session(:user_id, conn.private.cas_user.uid)
            |> Plug.Conn.put_resp_header("location", "/")
            |> Plug.Conn.send_resp(307, "")
        end
      current_user ->
        Logger.debug "#{conn.remote_ip |> Tuple.to_list|> Enum.join(".")} get user #{current_user} by session"

        key = get_session(conn,:userkey)
        uid = get_session(conn,:user_id)
        unless is_nil key do
          T1058.UserTable.add(key,{current_user,uid})
        else
          Logger.info "#{conn.remote_ip |> Tuple.to_list|> Enum.join(".")}  no userkey in session"
        end
        url = case get_session(conn,:returnurl) do
                nil -> T1058.Util.get_conf(:app_url)
                app_url -> app_url
              end
        conn 
          |> clear_session  ###????
          |> Plug.Conn.put_resp_header("location",url)
          |> Plug.Conn.send_resp(307, "")
    end
  end

  get "/user" do
    param_map = query_string_to_map(conn.query_string)    
    body = if Map.has_key?(param_map,"userkey") do
      case T1058.UserTable.search(param_map["userkey"] |> process_key ) do
        nil ->
          "unauthorized"
        {user_name,user_id} ->
          case T1058.User.query user_name do
            nil ->
              Logger.info "#{conn.remote_ip |> Tuple.to_list|> Enum.join(".")} get user #{user_name} info fail."
              "#{user_name} logined, but get user info fail"
              %{uid: user_id,loginaccount: user_name} |> Poison.encode!
            user_info ->
              is_map(user_info) |>  IO.inspect
              user_info |> Map.put(:uid,user_id) |> Poison.encode!
          end
      end
    else
      "ok"
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

  # defp conn_params_process({key,value}) do
  #   case key do
  #     "userkey" ->
  #       {:userkey, value |> process_key }
  #     _ ->
  #       {String.to_atom(key),value}
  #   end
  # end
  
  defp process_key(key) do
    key
  end
  
  defp add_conn_params!(conn,add_map) do
    %{conn | params: Map.merge(conn.params, add_map), query_string: ""}
  end

  defp add_conn_session!(conn,add_map) do
    Enum.reduce(add_map,conn, fn({k,v},conn) -> put_session(conn,k,v) end)
  end

  
  defp query_string_to_map(str) do
    str
    |> String.split("&")
    |> Enum.map( fn(x) -> String.split(x,"=") end )
    |> Map.new(fn x -> {List.first(x) |> String.downcase ,List.last(x)} end)
  end

  # defp map_to_query_string(m) do
  #   m
  #   |> Map.to_list
  #   |> Enum.map(&( &1 |> Tuple.to_list |> Enum.join("=")))
  #   |> Enum.join("&")
  # end    
end


