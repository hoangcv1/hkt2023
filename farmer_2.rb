require_relative 'api'
require_relative 'coin'
require_relative 'bot_game'
require_relative 'distance'
require 'json'
include Api
include Distance

token = 'c4b157e0-2f0b-4af9-a440-e3aa430f0ed1'
bot_name = '[Test] 72s'

join_board_api = Api::join(token, ENV['SELECTED_BOARD'].to_i)
if join_board_api.code == "200"
  p "Joined FARMER 1"
else
  p join_board_api.body
end

response = Api::get_board(ENV['SELECTED_BOARD'].to_i)
all_coins = []
all_bots = []
all_gates = []
my_bot = nil
danger_position = []

if response&.code == "200"
  response_json = JSON.parse(response.body)
  all_coins, all_bots, all_gates = Api::handle_game_objects(response_json['gameObjects'])
  my_bot = all_bots.find { |bot| bot.name == bot_name }
  my_bot.gate_positions = all_gates
end
start_time = Time.now
Thread.new do
  while start_time + 300 > Time.now do
    begin
      response = Api::get_board(ENV['SELECTED_BOARD'].to_i)
      response_json = JSON.parse(response.body)
      all_coins, all_bots, all_gates = Api::handle_game_objects(response_json['gameObjects'])
      all_bots.each { |bot|
        if bot.name == bot_name
          my_bot.position = bot.position
          my_bot.coins = bot.coins
          my_bot.score = bot.score
          my_bot.gate_positions = all_gates
        end
      }

      sleep 0.4
    rescue => exception
      p exception
    end
  end
end

while start_time + 300 > Time.now do
  if my_bot.coins < 5
    suitabled_coins = all_coins.select { |coin| coin.points <= (5 - my_bot.coins) }
    if suitabled_coins != []
      sleep 0.8
      my_bot.go_to_nearest_coin(suitabled_coins.map(&:position), token)
    else
      sleep 0.8
      my_bot.go_to_base token
    end
  else
    sleep 0.8
    my_bot.go_to_base token
  end
end
