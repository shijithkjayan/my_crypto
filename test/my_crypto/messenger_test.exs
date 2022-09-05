defmodule MyCrypto.MessengerTest do
  use ExUnit.Case


  import Mox
  setup :verify_on_exit!

  alias MyCrypto.Messenger
  alias MyCrypto.Messenger.HttpClientMock
end
