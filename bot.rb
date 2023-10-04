require_relative "api"
require_relative 'coin'
require 'json'

include Api

response = Api::get_board(8)

p response.code
p JSON.parse(response.body)
