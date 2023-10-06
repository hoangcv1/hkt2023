require_relative 'api'
require_relative 'coin'
require_relative 'bot_game'
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

if response&.code == "200"
  response_json = JSON.parse(response.body)
  response_json['gameObjects'].each do |obj|
    if obj['type'] == 'CoinGameObject'
      all_coins << Coin.new(**obj)
    end

    if obj['type'] == 'BotGameObject'
      all_bots << BotGame.new(**obj)
    end
  end
  my_bot = all_bots.find { |bot| bot.me }
  enemies = all_bots.select { |bot| bot.teamId != my_bot.teamId }
  bases = enemies.map(&:base)
  nearest_base = Distance::find_the_nearest(my_bot.position, bases)
  enemy = enemies.find { |e| e.base == nearest_base }
  enemy_id = enemy&.id
end

Thread.new do
  while true do
    response = Api::get_board(ENV['SELECTED_BOARD'].to_i)
    response_json = JSON.parse(response.body)
    temp_all_coins = []
    temp_all_bots = []

    response_json['gameObjects'].each do |obj|
      if obj['type'] == 'CoinGameObject'
        temp_all_coins << Coin.new(**obj)
      end

      if obj['type'] == 'BotGameObject'
        temp_all_bots << BotGame.new(**obj)
      end
    end

    all_coins = temp_all_coins
    all_bots = temp_all_bots
    my_bot = all_bots.find { |bot| bot.me }
    enemy = all_bots.find { |bot| bot.id == enemy_id }
    sleep 0.05
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
