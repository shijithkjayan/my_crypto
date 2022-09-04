ExUnit.start()

# Define mocks here
Mox.defmock(MyCrypto.Messenger.HttpClientMock, for: MyCrypto.Messenger.Http)
Mox.defmock(MyCrypto.CoinGecko.HttpClientMock, for: MyCrypto.CoinGecko.Http)
