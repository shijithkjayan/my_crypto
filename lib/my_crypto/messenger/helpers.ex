defmodule MyCrypto.Messenger.Helpers do
  @moduledoc """
  Generic helper functions to decode
  the incoming message and other functionalities.
  """

  @doc """
  Gets the message map from the payload
  """
  @spec get_message!(map) :: map()
  def get_message!(%{"entry" => [%{"messaging" => messaging} | _]}) when is_list(messaging) do
    [message_body | _] = messaging
    message_body
  end

  def get_message!(_) do
    raise(RuntimeError, "Invalid payload")
  end

  @doc """
  Gets the sender ID from the message.
  """
  @spec get_sender_id(map()) :: String.t()
  def get_sender_id(%{"sender" => %{"id" => sender_id}}), do: sender_id

  @doc """
  Gets the first name of the sender from the profile.
  """
  @spec get_name_from_profile(map()) :: String.t()
  def get_name_from_profile(%{"first_name" => f_name}), do: f_name
end
