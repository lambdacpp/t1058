defmodule T1058.UserTable do
  require Logger

  use GenServer

  @name T1058.UserTable 
  
  def start_link( opts \\[]) do
    GenServer.start_link(__MODULE__, :ok,opts)
  end

  def init(:ok) do
    {:ok, Map.new}
  end

  def add(key,value) do
    GenServer.call(@name, {:add,key,value})
  end

  def search(key) do
    GenServer.call(@name, {:search,key})
  end
  
  def handle_call({:add, key, username}, _from, user_map) do
    {:reply, true, user_map |> Map.put(key,username) }
  end
  
  def handle_call({:search, key}, _from, user_map) do
    if Map.has_key?(user_map,key) do
      {:reply, Map.get(user_map,key), user_map  }
    else
      {:reply, nil, user_map  }
    end
  end

  def handle_call(:show, _from, user_map) do
    {:reply, nil, user_map  }
  end

  
end
