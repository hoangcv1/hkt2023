class BotGame
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
