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

  def different_direction direction
    if [DIRECTION[:left], DIRECTION[:right]].include? direction
      [DIRECTION[:up], DIRECTION[:down]].sample
    else
      [DIRECTION[:left], DIRECTION[:right]].sample
    end
  end

  def euclidean_distance(point1, point2)
    Math.sqrt((point1['x'] - point2['x'])**2 + (point1['y'] - point2['y'])**2)
  end

  def nearest_base my_bot, enemy_bases
    distance_to_base1 = Distance::euclidean_distance(my_bot.base, enemy_bases[0])
    distance_to_base2 = Distance::euclidean_distance(my_bot.base, enemy_bases[1])
    if distance_to_base1 == distance_to_base2
      enemy_bases[ENV['SELECTED_BOT'] == 'BOT_2' ? 1 : 0]
    else
      Distance::find_the_nearest(my_bot.position, enemy_bases)
    end
  end

  def position_next_to_base_between_enemy_and_base(enemy_position, base_position)
    # Calculate the midpoint between the enemy and the base
    midpoint_x = (enemy_position['x'] + base_position['x']) / 2.0
    midpoint_y = (enemy_position['y'] + base_position['y']) / 2.0

    # Calculate the vector from the base to the midpoint
    vector_x = midpoint_x - base_position['x']
    vector_y = midpoint_y - base_position['y']

    # Normalize the vector (convert it to a unit vector)
    vector_length = Math.sqrt(vector_x ** 2 + vector_y ** 2)
    normalized_vector_x = vector_x / vector_length
    normalized_vector_y = vector_y / vector_length

    # Calculate the new position
    new_x = base_position['x'] + normalized_vector_x
    new_y = base_position['y'] + normalized_vector_y

    # Create and return the new position
    {
      'x' => new_x.to_i,
      'y' => new_y.to_i
    }
  end
end
