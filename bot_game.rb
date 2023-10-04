require 'dotenv'
Dotenv.load('.env')

DIRECTION = { up: 'UP', down: 'DOWN', left: 'LEFT', right: 'RIGHT' }

class BotGame
  attr_accessor :id, :position, :coins, :score, :name, :inventorySize, :canTackle, :millisecondsLeft, :timeJoined, :base, :teamId, :me

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
    @me = options['properties']['name'] == ENV['BOT_NAME']
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

    if nearest_coin_position["x"] > position["x"]
      Api::move(ENV["#{ENV['SELECTED_BOT']}"], DIRECTION[:right])
    elsif nearest_coin_position["x"] < position["x"]
      Api::move(ENV["#{ENV['SELECTED_BOT']}"], DIRECTION[:left])
    elsif nearest_coin_position["y"] > position["y"]
      Api::move(ENV["#{ENV['SELECTED_BOT']}"], DIRECTION[:down])
    else
      Api::move(ENV["#{ENV['SELECTED_BOT']}"], DIRECTION[:up])
    end
  end

  def euclidean_distance(point1, point2)
    Math.sqrt((point1['x'] - point2['x'])**2 + (point1['y'] - point2['y'])**2)
  end

  def return_base
    if position["x"] > base["x"]
      Api::move(ENV["#{ENV['SELECTED_BOT']}"], DIRECTION[:left])
    elsif position["x"] < base["x"]
      Api::move(ENV["#{ENV['SELECTED_BOT']}"], DIRECTION[:right])
    elsif position["y"] > base["y"]
      Api::move(ENV["#{ENV['SELECTED_BOT']}"], DIRECTION[:up])
    else
      Api::move(ENV["#{ENV['SELECTED_BOT']}"], DIRECTION[:down])
    end
  end

  def go_to_enemy_base enemy_position
    p "Go to enemy base"
    if position["x"] > enemy_position["x"]
      Api::move(ENV["#{ENV['SELECTED_BOT']}"], DIRECTION[:left])
    elsif position["x"] < enemy_position["x"]
      Api::move(ENV["#{ENV['SELECTED_BOT']}"], DIRECTION[:right])
    elsif position["y"] > enemy_position["y"]
      Api::move(ENV["#{ENV['SELECTED_BOT']}"], DIRECTION[:up])
    else
      Api::move(ENV["#{ENV['SELECTED_BOT']}"], DIRECTION[:down])
    end
  end
end

# {
#   "id": 399,
#   "position": {"x": 3, "y": 3},
#   "type": "BotGameObject",
#   "properties": {
#     "coins": 0,
#     "score": 0,
#     "name": "DaXua",
#     "inventorySize": 5,
#     "canTackle": true,
#     "millisecondsLeft": 221543,
#     "timeJoined": "2023-10-04T07:29:50.477Z",
#     "base": {"x": 3, "y": 3},
#     "teamId": "f4f51616-9f33-4c12-9a13-0f9a86fe8b70"
#   }
# }
