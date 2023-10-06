require 'dotenv'
require_relative 'distance'

include Distance
Dotenv.load('.env')

DIRECTION = { up: 'UP', down: 'DOWN', left: 'LEFT', right: 'RIGHT' }

class BotGame
  attr_accessor :id, :position, :coins, :score, :name, :inventorySize, :canTackle, :millisecondsLeft, :timeJoined, :base, :teamId, :me, :status, :enemy_id

  def initialize(**options)
    @id = options['id']
    @position = options['position']
    @coins = options['properties']['coins']
    @score = options['properties']['score']
    @name = options['properties']['name']
    @inventorySize = options['properties']['inventorySize']
    @canTackle = options['properties']['canTackle']
    @millisecondsLeft = options['properties']['millisecondsLeft']
    @timeJoined = options['properties']['timeJoined']
    @base = options['properties']['base']
    @teamId = options['properties']['teamId']
    @me = options['properties']['name'] == ENV["#{ENV["SELECTED_BOT"]}_NAME"]
    @status = "FARMING"
  end

  def go_to_nearest_coin coin_positions
    nearest_coin_position = Distance::find_the_nearest(position, coin_positions)

    go_to_target nearest_coin_position
  end

  def go_to_base
    go_to_target base
  end

  def go_to_enemy_base enemy_position
    go_to_target enemy_position
  end

  def go_to_target target_position
    if position['x'] > target_position['x']
      direction = DIRECTION[:left]
    elsif position['x'] < target_position['x']
      direction = DIRECTION[:right]
    elsif position['y'] > target_position['y']
      direction = DIRECTION[:up]
    else
      direction = DIRECTION[:down]
    end

    response = Api::move(ENV["#{ENV['SELECTED_BOT']}_TOKEN"], direction)
  end

  def enemy_nearby? enemy_position
    adjacent_horizontally = (position['x'] -  enemy_position['x']).abs == 1 && position['y'] == enemy_position['y']
    adjacent_vertically = position['x'] ==  enemy_position['x'] && (position['y'] - enemy_position['y']).abs == 1

    adjacent_horizontally || adjacent_vertically
  end
end
