module Distance
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

  def euclidean_distance(point1, point2)
    Math.sqrt((point1['x'] - point2['x'])**2 + (point1['y'] - point2['y'])**2)
  end
end
