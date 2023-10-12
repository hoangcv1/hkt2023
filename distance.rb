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

  def direction position, target_position
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

  def should_go_to_portal position, near_position, portals, enemy_base
    far_position = portal_positions.find { |portal_position| portal_position != near_position }
    temp_position = position.dup
    if temp_position['x'] < near_position['x']
      temp_position['x'] -= 2
    elsif temp_position['x'] > near_position['x']
      temp_position['x'] += 2
    elsif temp_position['y'] < near_position['y']
      temp_position['y'] -= 2
    elsif temp_position['y'] < near_position['y']
      temp_position['y'] += 2
    end

    distance_from_far_gate_to_enemy_base = euclidean_distance(enemy_base, far_position)
    distance_from_near_gate_to_enemy_base = euclidean_distance(enemy_base, temp_position)

    p "distance_from_far_gate_to_enemy_base: #{distance_from_far_gate_to_enemy_base}"
    p "distance_from_near_gate_to_enemy_base: #{distance_from_near_gate_to_enemy_base}"

    distance_from_far_gate_to_enemy_base < distance_from_near_gate_to_enemy_base
  end
end
