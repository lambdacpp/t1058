defmodule T1058 do
  use Application

  def start(_type, _args) do
    T1058.Supervisor.start_link
  end


end
