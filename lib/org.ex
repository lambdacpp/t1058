defmodule T1058.Org do
  @derive [Poison.Encoder]

  require Logger
  alias T1058.Post
  
  defstruct [:systemId,
             :id,
             :name,
             :type,
             :remarks,
             :address,
             :code,
             :email,
             :fax,
             :master,
             :phone,
             :zipCode,
             :parent_id,
             :parent_name,
             :org_remark,
             :up_time]

  def query do
    case :query |> url |> Post.httppost do
      {:error,message} ->
        Logger.info "Get Org list error,#{message}."
        []
      json_str ->
        json_str |> Poison.decode!(as: [%T1058.Org{}])
    end
  end

  def url(ops) do
    if ops in [:add,:delete,:update,:query] do
      ops_str = ops |> to_string |> String.upcase
      Application.get_env(:t1058, :cas_api_url)<>
        "orgdetRs/categoryservice/category/"<>
        Application.get_env(:t1058, :cas_api_sysid)<>
        "/" <>
        (ops_str |> to_string |> String.upcase )
    else
      nil
    end
  end

  def show_org_list(org_list) do
    "ID Type Name" |> IO.inspect
    Enum.each org_list,&(&1 |> to_str |> IO.inspect)
  end
  
  def to_str(org) do
    "#{org.id} #{org.type} #{org.name}"
  end
end


defimpl String.Chars, for: T1058.Org do
  def to_string(org), do: T1058.Org.to_str(org) 
end


