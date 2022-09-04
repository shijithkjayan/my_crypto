defmodule MyCrypto.Messenger.Http do
  @moduledoc """
  HTTP behaviour for Messenger HTTP Client.
  """

  @callback send_reply(map()) :: :ok
  @callback get_user_name(String.t()) :: String.t()
end
