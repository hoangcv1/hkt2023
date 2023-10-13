module Distance
  DIRECTION = { up: 'UP', down: 'DOWN', left: 'LEFT', right: 'RIGHT' }

  def find_the_nearest position = {}, targets = []
    nearest_target = nil
    min_distance = Float::INFINITY
    targets.each do |target|
      distance = euclidean_distance(position, target)
      if distance < min_distance
        min_distance = distance
        nearest_target = target
      end
    end

    nearest_target
  end

  def find_all_around position = {}
    [
      { 'x'=> position['x'],     'y' => position['y'] - 1 },  # Top
      { 'x'=> position['x'] - 1, 'y' => position['y']     },  # Left
      { 'x'=> position['x'] + 1, 'y' => position['y']     },  # Right
      { 'x'=> position['x'],     'y' => position['y'] + 1 }   # Bottom
    ]
  end

  def possible_target position = {}, direction = 'left'
    if direction == DIRECTION[:up]
      {
        'x' => position['x'],
        'y' => position['y'] - 1
      }
    elsif direction == DIRECTION[:down]
      {
        'x' => position['x'],
        'y' => position['y'] + 1
      }
    elsif direction == DIRECTION[:left]
      {
        'x' => position['x'] - 1,
        'y' => position['y']
      }
    elsif direction == DIRECTION[:right]
      {
        'x' => position['x'] + 1,
        'y' => position['y']
      }
    end
  end

  def get_direction position, target_position
    if position['x'] - target_position['x'] == 1
      DIRECTION[:left]
    elsif target_position['x'] - position['x'] == 1
      DIRECTION[:right]
    elsif position['y'] - target_position['y'] == 1
      DIRECTION[:up]
    elsif target_position['y'] - position['y'] == 1
      DIRECTION[:down]
    end
  end

  def possible_directions position, target_position
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

    possible_directions
  end

  def possible_target_positions position, target_position
    possible_directions = possible_directions(position, target_position)
    possible_directions.map { |direction| possible_target(position, direction)}
  end

  def euclidean_distance(point1, point2)
    Math.sqrt((point1['x'] - point2['x'])**2 + (point1['y'] - point2['y'])**2)
  end

  def nearest_base my_bot, enemy_bases
    distance_to_base1 = euclidean_distance(my_bot.base, enemy_bases[0])
    distance_to_base2 = euclidean_distance(my_bot.base, enemy_bases[1])
    if distance_to_base1 == distance_to_base2
      enemy_bases[ENV['SELECTED_BOT'] == 'BOT_2' ? 1 : 0]
    else
      find_the_nearest(my_bot.position, enemy_bases)
    end
  end

  def get_number_of_steps(position, target)
    (position['x'] - target['x']).abs + (position['y'] - target['y']).abs
  end

  def should_go_to_gate position, near_position, gates, target
    far_position = gate_positions.find { |gate_position| gate_position != near_position }
    temp_position = position.dup
    ratio = 1
    ratio = 2 if position['x'] == target['x'] || position['y'] == target['y']

    if temp_position['x'] < near_position['x']
      temp_position['x'] -= ratio
    elsif temp_position['x'] > near_position['x']
      temp_position['x'] += ratio
    elsif temp_position['y'] < near_position['y']
      temp_position['y'] -= ratio
    elsif temp_position['y'] < near_position['y']
      temp_position['y'] += ratio
    end

    steps_from_far_gate_to_target = get_number_of_steps(target, far_position)
    steps_from_near_gate_to_target = get_number_of_steps(target, temp_position)
    steps_from_far_gate_to_target <= steps_from_near_gate_to_target
  end

  def get_different_direction position, target_position
    direction = get_direction(position, target_position)
    if [DIRECTION[:left], DIRECTION[:right]].include? direction
      [DIRECTION[:up], DIRECTION[:down]].sample
    else
      [DIRECTION[:left], DIRECTION[:right]].sample
    end
  end

  def get_not_return_postion position, my_base, enemy_base
    not_return = [enemy_base]
    vertical_position = [
      {
        'x' => enemy_base['x'],
        'y' => enemy_base['y'] - 1
      },
      {
        'x' => enemy_base['x'],
        'y' => enemy_base['y'] + 1
      }
    ]

    horizontal_position = [
      {
        'x' => enemy_base['x'] - 1,
        'y' => enemy_base['y']
      },
      {
        'x' => enemy_base['x'] + 1,
        'y' => enemy_base['y']
      }
    ]
    if my_base['x'] == enemy_base['x']
      if my_base['y'] > enemy_base['y']
        if position['y'] > enemy_base['y']
          not_return + vertical_position
        else
          not_return
        end
      else
        if position['y'] < enemy_base['y']
          not_return + vertical_position
        else
          not_return
        end
      end
    else
      if my_base['x'] > enemy_base['x']
        if position['x'] < enemy_base['x']
          not_return + horizontal_position
        else
          not_return
        end
      else
        if position['x'] > enemy_base['x']
          not_return + horizontal_position
        else
          not_return
        end
      end
    end
  end
end
