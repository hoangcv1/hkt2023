require 'dotenv'
Dotenv.load('.env')

DIRECTION = { up: 'UP', down: 'DOWN', left: 'LEFT', right: 'RIGHT' }

class BotGame
  attr_accessor :id, :position, :coins, :score, :name, :inventorySize, :canTackle, :millisecondsLeft, :timeJoined, :base, :teamId, :me, :status

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
    nearest_coin_position = nil
    min_distance = Float::INFINITY
    coin_positions.each do |coin_position|
      distance = euclidean_distance(position, coin_position)
      if distance < min_distance
        min_distance = distance
        nearest_coin_position = coin_position
      end
    end

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

    Api::move(ENV["#{ENV['SELECTED_BOT']}_TOKEN"], direction)
  end

  def enemy_nearby? enemy_position
    adjacent_horizontally = (position['x'] -  enemy_position['x']).abs == 1 && position['y'] == enemy_position['y']
    adjacent_vertically = position['x'] ==  enemy_position['x'] && (position['y'] - enemy_position['y']).abs == 1

    adjacent_horizontally || adjacent_vertically
  end

  private

  def euclidean_distance(point1, point2)
    Math.sqrt((point1['x'] - point2['x'])**2 + (point1['y'] - point2['y'])**2)
  end
end
