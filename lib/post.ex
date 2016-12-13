defmodule T1058.Post do
  require Logger
  
  def httppost(url,json_str \\ nil) do
    Logger.debug "POST to #{url}" 
    result = case json_str do
      nil ->
        HTTPotion.post url
      _ ->
        Logger.debug "POST json: #{json_str}" 
        encrypt_str = T1058.AES.encrypt(json_str)
        HTTPotion.post url,[body: "data=#{encrypt_str}"]
    end
                 
    case result do
      %HTTPotion.Response{body: body, status_code: 200} ->
        Logger.debug "POST success"
        body |> T1058.AES.decrypt        
      %HTTPotion.Response{status_code: scode} ->
        Logger.debug "POST status code: #{scode}" 
        {:error,"status code : #{scode}" }
      _ ->
        Logger.debug "POST http error" 
        {:error,"other error" }
    end
  end

  def struct_to_map struct do
    struct
    |> Map.from_struct
    |> Map.to_list
    |> Enum.filter(fn ({_,value}) -> not is_nil(value) end)
    |> Map.new
  end
  
end
