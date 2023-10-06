class Coin
  attr_accessor :id, :position, :points

  def initialize(**options)
    @id = options['id']
    @position = options['position']
    @points = options['properties']['points']
  end
end
