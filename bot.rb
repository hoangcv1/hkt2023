require_relative 'api'
require_relative 'coin'
require_relative 'bot_game'
require 'json'
include Api

response = Api::get_board(8)
response_json = JSON.parse(response.body)
COINS = []
BOTS = []
response_json['gameObjects'].each do |obj|
  if obj['type'] == 'CoinGameObject'
    COINS << Coin.new(**obj)
  end

  if obj['type'] == 'BotGameObject'
    BOTS << BotGame.new(**obj)
  end
end

p response.code
p JSON.parse(response.body)
