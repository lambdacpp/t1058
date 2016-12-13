defmodule T1058.AES do

  @aes_block_size 16
  
  def encrypt(plaintext) do
    encrypt(plaintext,key) 
  end

  def decrypt(ciphertext) do
    decrypt(ciphertext,key) 
  end

  def encrypt(data, key) do
    :crypto.block_encrypt(:aes_ecb,key,pad(data, @aes_block_size))
    |> Base.encode16(case: :lower)
  end
  
  def decrypt(data, key) do
    case Base.decode16(data, case: :lower) do
      {:ok,udata} ->
        :crypto.block_decrypt(:aes_ecb, key, udata)
        |> unpad
        |> String.graphemes
        |> Enum.reduce(fn(e,acc) -> acc<>e end)
      _ ->
        ""
    end
  end

  def pad(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> to_string(:string.chars(to_add, to_add))
  end

  def unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end
  

  # Convenience function to get the application's configuration key.
  defp key do
    Application.get_env(:t1058, :cas_api_key)
  end
  
end




# url = "http://218.6.169.98/nj/service/orgdetRs/categoryservice/category/20014962214/QUERY"
#  http://218.6.169.98/nj/service/categoryservice/category/20014962214/QUERY_SYS
#  %HTTPotion.Response{body: body, status_code: 200} = HTTPotion.post url
#  :crypto.aes_cbc_256_encrypt(key, IVec, pkcs5_padding(Text, 16))
