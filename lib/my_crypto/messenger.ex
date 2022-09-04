defmodule MyCrypto.Messenger do

  @token System.get_env("MESSENGER_VERIFY_TOKEN")

  def validate_verify_token(@token), do: true

  def validate_verify_token(_), do: false
end
