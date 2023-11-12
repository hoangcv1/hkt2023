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
  :status,
  :enemy_base,
  :gate_positions,
  :not_return_position,
  :enemy_positions,
  :enemy_scores

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
    @status = "FARMING"
    @not_return_position = []
    @enemy_positions = []
    @enemy_scores = 0
  end

  def go_to_nearest_coin coin_positions, token = nil
    nearest_coin_position = find_the_nearest(position, coin_positions)

    go_to_target nearest_coin_position, false, token
  end

  def go_to_base token = nil
    go_to_target base, false, token
  end

  def go_to_enemy_base enemy_position
    go_to_target enemy_position
  end

  def go_to_target target_position, force = false, token = nil
    token = token || ENV["#{ENV['SELECTED_BOT']}_TOKEN"]

    if force
      move(token, get_direction(position, target_position))
    else
      possible_target_positions = possible_target_positions(position, target_position)
      danger_positions = enemy_positions.flat_map { |pos| find_all_around(pos) } - [base]
      possible_target_positions = possible_target_positions - danger_positions - not_return_position
      unless possible_target_positions.empty?
        if gate_positions.any? { |gate| possible_target_positions.include? gate }
          self.not_return_position = []

          if should_go_to_gate(position, (possible_target_positions & gate_positions)[0], gate_positions, target_position)
            gate = (possible_target_positions & gate_positions)[0]
            move(token, get_direction(position, gate))
          else
            self.not_return_position << position
            if (possible_target_positions.count == 1)
              response = move(token, get_different_direction(position, possible_target_positions[0]))
            else
              not_gate = (possible_target_positions - gate_positions)[0]
              response = move(token, get_direction(position, not_gate))
            end
          end
        else
          move(token, get_direction(position, possible_target_positions.sample))
        end
      else
        if status == "RETURN"
          move(token, opposite_directions(position, target_position).sample)
        end
      end
    end
  end

  def nearby_enemy current_enemy_positions
    current_enemy_positions.each do |enemy_pos|
      p enemy_pos
      p position
      adjacent_horizontally = (position['x'] -  enemy_pos['x']).abs == 1 && position['y'] == enemy_pos['y']
      adjacent_vertically = position['x'] ==  enemy_pos['x'] && (position['y'] - enemy_pos['y']).abs == 1

      if (adjacent_horizontally || adjacent_vertically)
        p "should break here"
        return enemy_pos
        break
      else
        return false
      end
    end
  end

  def enemy_nearby? enemy_position
    adjacent_horizontally = (position['x'] -  enemy_position['x']).abs == 1 && position['y'] == enemy_position['y']
    adjacent_vertically = position['x'] ==  enemy_position['x'] && (position['y'] - enemy_position['y']).abs == 1

    adjacent_horizontally || adjacent_vertically
  end

  def coin_nearby? coin_positions
    coin_positions & nearby_positions
  end

  def nearby_positions
    [
      {
        'x' => position['x'],
        'y' => position['y'] + 1
      },
      {
        'x' => position['x'],
        'y' => position['y'] - 1
      },
      {
        'x' => position['x'] + 1,
        'y' => position['y']
      },
      {
        'x' => position['x'] - 1,
        'y' => position['y']
      }
    ]
  end
end
