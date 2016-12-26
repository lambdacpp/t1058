defmodule T1058.User do
  @derive [Poison.Encoder]
  require Logger
  
  alias T1058.Post
  
  defstruct [:loginaccount,
             :uid,
             :username,
             :password,
             :telephone,
             :orgDept,
             :orgid,
             :deptid,
             :address,
             :sex,
             :card,
             :email]

  def query(loginaccount) do
    json_str = Poison.encode!([%{loginaccount: loginaccount}])
    
    case :query |> url |> Post.httppost(json_str) do
      {:error,message} ->
        Logger.info "Get user #{loginaccount} error,#{message}."
        nil
      json_str ->
        json_str |> Poison.decode!(as: [%T1058.User{}]) |> List.first
    end
  end

  def add(user) do
    json_str =
    if Map.has_key?(user,:__struct__) do
      Poison.encode!([Post.struct_to_map(user)])
    else
      Poison.encode!([user])
    end

    case :add |> url |> Post.httppost(json_str) do
      {:error,message} ->
        Logger.info "Create user error,#{message}."
        false
      json_result ->
        Logger.debug "Create user result,#{json_result}."
        result = Poison.decode!(json_result,as: [Map]) |> List.first
        if result["status"] == 1 do
          Logger.info "Create user #{user.username} success."
          true
        else
          Logger.info "Create user #{user.username} fail,#{result["msg"]}."
          false
        end
    end
  end

  def delete(loginaccount) do
    json_str = Poison.encode!([%{loginaccount: loginaccount}])
    
    case :delete |> url |> Post.httppost(json_str) do
      {:error,message} ->
        Logger.info "Delete user error,#{message}."
        false
      json_result ->
        result = Poison.decode!(json_result,as: [Map]) |> List.first
        if result["status"] == 1 do
          Logger.info "Delete user #{loginaccount} success."
          true
        else
          Logger.info "Delete user #{loginaccount} fail,#{result["msg"]}."
          false
        end
    end
    
  end
  
  def url(ops)do
    if ops in [:add,:delete,:update,:query] do
      ops_str = ops |> to_string |> String.upcase
      T1058.Util.get_conf(:cas_api_url) <>
        "categoryservice/category/" <>
        T1058.Util.get_conf(:cas_api_sysid)<>
        "/USER_OP/" <>
        (ops_str |> to_string |> String.upcase )
    else
      nil
    end
  end

  def to_str(user) do
    "Accout:#{user.loginaccount},Name:#{user.username},Orgid:#(user.orgid),Depid:#{user.deptid},Dept:#{user.orgDept}"
  end
end


defimpl String.Chars, for: T1058.User do
  def to_string(user), do: T1058.User.to_str(user)
end

