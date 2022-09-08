# MyCrypto

## Scopes:
- The precision of coin prices is set to 10.
- As mentioned in the problem, a coins prices in the last 14 days will be displayed to the user. But the total list will contain 15 values since CoinGecko returns two prices for today's date.


## Improvements
- We can cache the prices of a coin when its called for the first time in a day and keep its `ttl` as EOD and there by limit the number of API calls to CoinGecko.

- A I tried out to force the flow was to ask the user to do their coin search as thread/reply to the previous message the bot sends them. So when the user replies, the bot will get the previous message's ID which the bot can use to call the Message Graph API and get the message content and ensure that its what we expect. But to do that the bot/page needs more permission which needs App review and is going to take time, so I had to drop it.

- For now, I have used ETS to force a the flow. This was needed because I couldnt find a way to match the case when a user is sending a coin search request, so whenever a user enters any message other than `Hi` or `Hello` the bot will consider that as a search request and try to get the coins that match the message.
In order to avoid that, by using ETS I have set states for the user/sender and also gave it a ttl of 1 minute. So a message will be considered as a coin search only when the state of the user is `search_by` (which is the step that user is supposed to pass through right before they try to make a coin search request.) and the ttl is not expired. We assume that the interaction is active for only 1 minute, past that the bot considers the chat as ended and the user should start over.
So basically this ETS caching is only to force a flow to the coversation.

- The ETS table for now is kept as public. It can be made private and all its action can be handled within a Genserver. But for now, to make things simple and easy I have made it public.

## Working Examples
![RPReplay_Final1662568656](https://user-images.githubusercontent.com/41006127/188940644-cc274a4a-8a5c-46f6-bcc9-924c026e8e7f.mov)

![Screen Recording 2022-09-07 at 10 18 38 PM](https://user-images.githubusercontent.com/41006127/188940682-06e7aa06-ee6f-48ae-8f26-39e2bddd1541.mov)

## Problem:
Help investors evaluate cryptocurrencies using facebook messenger chatbot. The conversation should go like this:
### Conversation
  1. Welcome the user by using their first name.
  2. Ask the user if they want to search coins by name or by ID (Coins ID).
  3. Use CoinGecko API to search coins.
  4. Retrieve a maximum of 5 coins and let the user select one of them.
  5. Retrieve the selected coin’s prices in USD for the last 14 days from CoinGecko (get it from market chart).

### Specification
  1. Don’t use any chatbot framework or service for doing the task.
  2. You must handle the flow of the conversation by yourself.
  3. Get the best test coverage you can get.
  4. In case you are applying for a mid-level position or higher, you are required to add the deployment script or virtualenv provisioning script to the repo.
  5. In case you are applying for a mid-level position or higher, test coverage should be 60% or more.


## Checklist
- [x] Handle the flow of the conversation
- [x] Have 60% or higher test coverage - Current test coverage is 95.2%
- [x] Deploy - Deployed to Fly.io

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create a .envrc.custom file and `FB_PAGE_ACCESS_TOKEN` and `MESSENGER_VERIFY_TOKEN` values there
  * You can either use `direnv` to load your env variables or type `source .envrc` in your shell to load it.
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
