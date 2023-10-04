class Coin
  def initialize(**options)
    @id = options['id']
    @position = options['position']
    @points = options['properties']['points']
 end

 def display_details
    puts id
    puts position
    puts points
 end
end
