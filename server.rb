require_relative 'api'
require_relative 'coin'
require_relative 'bot_game'
require_relative 'distance'
require 'json'
include Api
include Distance

response = Api::join(ENV["#{ENV['SELECTED_BOT']}_TOKEN"], ENV['SELECTED_BOARD'].to_i)
if response.code == "200"
  p "Joined #{ENV['SELECTED_BOT']}"
else
  p response.body
end

response = Api::get_board(ENV['SELECTED_BOARD'])
enemy_id = 0
all_coins = []
all_bots = []
all_portals = []
my_bot = nil
enemy = nil
enemy_positions = []
danger_position = []

if response&.code == "200"
  response_json = JSON.parse(response.body)
  all_coins, all_bots, all_portals = Api::handle_game_objects(response_json['gameObjects'])
  my_bot = all_bots.find { |bot| bot.me }
  enemies = all_bots.select { |bot| bot.teamId != my_bot.teamId }
  enemy_bases = enemies.map(&:base)
  nearest_base = Distance::nearest_base(my_bot, enemy_bases)
  enemy = enemies.find { |e| e.base == nearest_base }
  enemy_positions = all_bots.select { |bot| !bot.me }.map(&:position).flat_map { |pos| Distance::find_all_around(pos) }
  my_bot.danger_positions = enemy_positions
  my_bot.portal_positions = all_portals
end

Thread.new do
  while true do
    begin
      response = Api::get_board(ENV['SELECTED_BOARD'].to_i)
      response_json = JSON.parse(response.body)

      all_coins, all_bots, all_portals = Api::handle_game_objects(response_json['gameObjects'])
      all_bots.each { |bot|
        if bot.me
          my_bot.position = bot.position
          my_bot.coins = bot.coins
          my_bot.score = bot.score
          my_bot.danger_positions = enemy_positions
          my_bot.portal_positions = all_portals
        end
      }

      enemies = all_bots.select { |bot| bot.teamId != my_bot.teamId }
      enemy_bases = enemies.map(&:base)
      nearest_base = Distance::nearest_base(my_bot, enemy_bases)
      enemy = enemies.find { |e| e.base == nearest_base }
      enemy_positions = all_bots.select { |bot| !bot.me }.map(&:position).flat_map { |pos| Distance::find_all_around(pos) }

      sleep 0.05
    rescue => exception
      p exception
    end
  end
end

while my_bot.score == 0 do
  if my_bot.coins == 0
    start_time = my_bot.go_to_nearest_coin(all_coins.map(&:position))
    sleep 0.8
  else
    start_time = my_bot.go_to_base
    sleep 0.8
  end
end

while (true) do
  if (enemy)
    while my_bot.position != enemy.base do
      my_bot.go_to_enemy_base enemy.base, enemy.position
      sleep 0.8
    end

    while my_bot.position == enemy.base do
      killed = false
      while (!killed) do
        p "Waiting for enemy"
        if (my_bot.enemy_nearby? enemy.position)
          p "Kill"
          my_bot.go_to_target enemy.position
          killed = true
        end
        sleep 0.2
      end
    end

    while my_bot.position != my_bot.base do
      my_bot.go_to_base
      sleep 0.8
    end
  else
    p "enemy not found"
    sleep 5
  end
end
