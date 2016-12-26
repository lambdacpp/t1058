defmodule T1058.Util do
  def get_conf(key) do
    case System.get_env(key |> Atom.to_string |> String.upcase) do
      nil ->
        Application.get_env(:t1058, key)
      value ->
        value
    end
  end
end
