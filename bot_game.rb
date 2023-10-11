require 'dotenv'
require_relative 'distance'

include Distance
Dotenv.load('.env')

DIRECTION = { up: 'UP', down: 'DOWN', left: 'LEFT', right: 'RIGHT' }

class BotGame
  attr_accessor :id,
  :position,
  :coins,
  :score,
  :name,
  :inventorySize,
  :base,
  :teamId,
  :me,
  :enemy_id,
  :danger_positions,
  :portal_positions

  def initialize(**options)
    @id = options['id']
    @position = options['position']
    @coins = options['properties']['coins']
    @score = options['properties']['score']
    @name = options['properties']['name']
    @inventorySize = options['properties']['inventorySize']
    @base = options['properties']['base']
    @teamId = options['properties']['teamId']
    @me = options['properties']['name'] == ENV["#{ENV["SELECTED_BOT"]}_NAME"]
  end

  def go_to_nearest_coin coin_positions
    p "go_to_nearest_coin"
    nearest_coin_position = Distance::find_the_nearest(position, coin_positions)

    go_to_target nearest_coin_position
  end

  def go_to_base
    p "go_to_base"
    go_to_target base
  end

  def go_to_enemy_base enemy_base, enemy_position
    p "go_to_enemy_base"

    if enemy_position != enemy_base
      target_position = Distance::position_next_to_base_between_enemy_and_base(enemy_position, enemy_base)
    else
      target_position = enemy_base
    end

    p target_position
    go_to_target target_position
  end

  def go_to_target target_position
    possible_directions = []

    if position['x'] > target_position['x']
      possible_directions << DIRECTION[:left]
    elsif position['x'] < target_position['x']
      possible_directions << DIRECTION[:right]
    end

    if position['y'] > target_position['y']
      possible_directions << DIRECTION[:up]
    elsif position['y'] < target_position['y']
      possible_directions << DIRECTION[:down]
    end
    possible_target_positions = possible_directions.map { |direction| Distance::possible_target(position, direction)}
    unless (possible_target_positions - danger_positions).empty?
      if possible_target_positions.any? { |position| portal_positions.include?(position)}
        p "Meet portal"
        response = Api::move(ENV["#{ENV['SELECTED_BOT']}_TOKEN"], Distance::different_direction(Distance::direction(position, possible_target_positions.sample)))
        p response.code
      else
        response = Api::move(ENV["#{ENV['SELECTED_BOT']}_TOKEN"], Distance::direction(position, possible_target_positions.sample))
        p response.code
      end
    else
      p "Nowhere to go"
    end
  end

  def enemy_nearby? enemy_position
    adjacent_horizontally = (position['x'] -  enemy_position['x']).abs == 1 && position['y'] == enemy_position['y']
    adjacent_vertically = position['x'] ==  enemy_position['x'] && (position['y'] - enemy_position['y']).abs == 1

    adjacent_horizontally || adjacent_vertically
  end
end
