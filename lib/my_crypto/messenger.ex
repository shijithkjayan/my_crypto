defmodule MyCrypto.Messenger do

  @token System.get_env("MESSENGER_VERIFY_TOKEN")

  @doc """
  Validate the recieved token is same as what we have in the
  system. Returns true when its same and false otherwise.

  ## Examples

      iex> validate_verify_token("abcd")
      true

      iex> validate_verify_token(1234)
      false

  """
  @spec validate_verify_token(String.t()) :: boolean()
  def validate_verify_token(@token), do: true

  def validate_verify_token(_), do: false
end
