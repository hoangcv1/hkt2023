require_relative 'api'
require_relative 'coin'
require_relative 'bot_game'
require_relative 'distance'
require 'json'
include Api
include Distance

response = Api::join(ENV["#{ENV['SELECTED_BOT']}_TOKEN"], ENV['SELECTED_BOARD'].to_i)
response = Api::get_board(ENV['SELECTED_BOARD'])
enemy_id = 0
all_coins = []
all_bots = []
my_bot = nil
enemy = nil
enemy_positions = []
danger_position = []
temp_all_portals = []

if response&.code == "200"
  response_json = JSON.parse(response.body)
  response_json['gameObjects'].each do |obj|
    if obj['type'] == 'CoinGameObject'
      all_coins << Coin.new(**obj)
    end

    if obj['type'] == 'BotGameObject'
      all_bots << BotGame.new(**obj)
    end

    if obj['type'] == 'GateGameObject'
      temp_all_portals << obj['position']
    end
  end
  my_bot = all_bots.find { |bot| bot.me }
  enemies = all_bots.select { |bot| bot.teamId != my_bot.teamId }
  bases = enemies.map(&:base)
  nearest_base = Distance::find_the_nearest(my_bot.position, bases)
  enemy = enemies.find { |e| e.base == nearest_base }
  enemy_id = enemy&.id
  enemy_positions = all_bots.select { |bot| !bot.me }.map(&:position).flat_map { |pos|
    Distance::find_all_around(pos)
  }
  my_bot.danger_positions = enemy_positions + temp_all_portals
end

Thread.new do
  while true do
    response = Api::get_board(ENV['SELECTED_BOARD'].to_i)
    response_json = JSON.parse(response.body)
    temp_all_coins = []
    temp_all_bots = []
    temp_all_portals = []

    response_json['gameObjects'].each do |obj|
      if obj['type'] == 'CoinGameObject'
        temp_all_coins << Coin.new(**obj)
      end

      if obj['type'] == 'BotGameObject'
        temp_all_bots << BotGame.new(**obj)
      end

      if obj['type'] == 'GateGameObject'
        temp_all_portals << obj['position']
      end
    end

    all_coins = temp_all_coins
    all_bots = temp_all_bots
    all_bots.each { |bot|
      if bot.me
        my_bot.position = bot.position
        my_bot.coins = bot.coins
        my_bot.score = bot.score
        my_bot.danger_positions = enemy_positions + temp_all_portals
      end
    }

    enemy = all_bots.find { |bot| bot.id == enemy_id }
    enemy_positions = all_bots.select { |bot| !bot.me }.map(&:position).flat_map { |pos|
      Distance::find_all_around(pos)
    }

    sleep 0.2
  end
end

while my_bot.score == 0 do
  if my_bot.coins == 0
    my_bot.go_to_nearest_coin(all_coins.map(&:position))
    sleep 0.8
  else
    my_bot.go_to_base
    sleep 0.8
  end
end

while (true) do
  while my_bot.position != enemy.base do
    my_bot.go_to_enemy_base enemy.base
    sleep 0.8
  end

  while my_bot.position == enemy.base do
    killed = false
    while (!killed) do
      if (my_bot.enemy_nearby? enemy.position)
        my_bot.go_to_target enemy.position
        killed = true
      end
      sleep 0.05
    end
  end

  while my_bot.position != my_bot.base do
    my_bot.go_to_base
    sleep 0.8
  end
end
