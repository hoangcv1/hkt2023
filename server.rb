require_relative 'api'
require_relative 'coin'
require_relative 'bot_game'
require_relative 'distance'
require 'json'
include Api
include Distance

join_board_api = join(ENV["#{ENV['SELECTED_BOT']}_TOKEN"], ENV['SELECTED_BOARD'].to_i)
if join_board_api.code == "200"
  p "Joined #{ENV["#{ENV["SELECTED_BOT"]}_NAME"]}"
else
  p join_board_api.body
end

response = get_board(ENV['SELECTED_BOARD'])
enemy_id = 0
all_coins = []
all_bots = []
all_gates = []
my_bot = nil
enemy = nil
enemy_positions = []
danger_position = []
high_coins = []

# "check started"
# while (JSON.parse(response.body)["isStarted"] != "true") do
#   sleep 1
#   response = get_board(ENV['SELECTED_BOARD'])
# end

if response&.code == "200"
  response_json = JSON.parse(response.body)
  all_coins, all_bots, all_gates = handle_game_objects(response_json['gameObjects'])
  my_bot = all_bots.find { |bot| bot.me }
  enemies = all_bots.select { |bot| bot.teamId != my_bot.teamId }
  nearest_base = nearest_base(my_bot, enemies.map(&:base))
  enemy = enemies.find { |e| e.base == nearest_base }
  enemy_id = enemy&.id
  my_bot.enemy_positions = all_bots.select { |bot| !bot.me }.map(&:position)
  my_bot.gate_positions = all_gates
  my_bot.enemy_base = nearest_base
end

Thread.new do
  while true do
    begin
      response = get_board(ENV['SELECTED_BOARD'].to_i)
      response_json = JSON.parse(response.body)
      all_coins, all_bots, all_gates = handle_game_objects(response_json['gameObjects'])
      enemy_positions = all_bots.select { |bot| !bot.me }.map(&:position)
      enemy = all_bots.find { |bot| bot.id == enemy_id }

      all_bots.each { |bot|
        if bot.me
          my_bot.position = bot.position
          my_bot.coins = bot.coins
          my_bot.score = bot.score
          my_bot.enemy_positions = enemy_positions
          my_bot.gate_positions = all_gates
          my_bot.status = "RETURN" if ([4, 5].include?(my_bot.coins))
        end
      }

      high_coins = all_coins.select { |coin| coin.points >= 2 }

      sleep 0.01
    rescue => exception
      p exception
    end
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

my_bot.status = "HUNTING"

while (true) do
  case my_bot.status
  when "RETURN"
    sleep 0.8
    if (my_bot.enemy_nearby? enemy.position)
      my_bot.go_to_target enemy.position, true
      my_bot.not_return_position << get_not_return_postion(my_bot.position, my_bot.base, enemy.base)
    elsif my_bot.enemy_nearby?(enemy_positions.reject { |p| p == enemy.position }[0])
      my_bot.go_to_target(enemy_positions.reject { |p| p == enemy.position }[0], true)
      my_bot.not_return_position << get_not_return_postion(my_bot.position, my_bot.base, enemy.base)
    else
      my_bot.go_to_base
    end

    if my_bot.position == my_bot.base
      nearby_high_coins = high_coins.map { |coin| get_number_of_steps(my_bot.base, coin.position) }.select{ |x| x < 3 }
      unless nearby_high_coins.empty?
        my_bot.status = "FARMING"
      else
        my_bot.not_return_position = []
        my_bot.status = "HUNTING"
      end
    end
  when "FARMING"
    sleep 0.8
    if (my_bot.enemy_nearby? enemy.position)
      my_bot.go_to_target enemy.position, true
      my_bot.not_return_position << get_not_return_postion(my_bot.position, my_bot.base, enemy.base)
    elsif my_bot.enemy_nearby?(enemy_positions.reject { |p| p == enemy.position }[0])
      my_bot.go_to_target(enemy_positions.reject { |p| p == enemy.position }[0], true)
      my_bot.not_return_position << get_not_return_postion(my_bot.position, my_bot.base, enemy.base)
    end

    my_bot.go_to_nearest_coin(all_coins.map(&:position))
    my_bot.status = "RETURN" if my_bot.coins >= 2
  when "HUNTING"
    sleep 0.8
    # if (my_bot.position['x'] == enemy.position['x'] == my_bot.base.position['x'] == enemy.base.position['x'])
    if (my_bot.enemy_nearby? enemy.position)
      my_bot.go_to_target enemy.position, true
      my_bot.not_return_position << get_not_return_postion(my_bot.position, my_bot.base, enemy.base)
    elsif my_bot.enemy_nearby?(enemy_positions.reject { |p| p == enemy.position }[0])
      my_bot.go_to_target(enemy_positions.reject { |p| p == enemy.position }[0], true)
      my_bot.not_return_position << get_not_return_postion(my_bot.position, my_bot.base, enemy.base)
    else
      my_bot.go_to_target camp_position(enemy)
    end

    if my_bot.position == camp_position(enemy)
      my_bot.status = "WAITING"
      my_bot.not_return_position = []
    end
  when "WAITING"
    if (my_bot.position == camp_position(enemy))
      if (my_bot.enemy_nearby? enemy.position)
        my_bot.go_to_target enemy.position, true
        my_bot.not_return_position << get_not_return_postion(my_bot.position, my_bot.base, enemy.base)
        my_bot.status = "RETURN"
      elsif my_bot.enemy_nearby?(enemy_positions.reject { |p| p == enemy.position }[0])
        my_bot.go_to_target(enemy_positions.reject { |p| p == enemy.position }[0], true)
        my_bot.not_return_position << get_not_return_postion(my_bot.position, my_bot.base, enemy.base)
        my_bot.status = "RETURN"
      end
      sleep 0.05
    else
      sleep 0.8
      my_bot.go_to_target camp_position(enemy)
    end
  end
end
