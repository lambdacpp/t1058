defmodule T1058.Supervisor do
  use Supervisor
  @name T1058.Supervisor
  @usertable T1058.UserTable 
  
  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end


  
  def init(:ok) do
    children = [
      worker(T1058.UserTable, [[name: @usertable]])
    ]
    supervise(children, strategy: :one_for_one)
  end

end
