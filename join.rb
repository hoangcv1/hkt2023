require_relative "api"
require 'json'
require 'dotenv'
Dotenv.load('.env')

include Api

response = Api::join(ENV["BOT_1_ID"], 8)

p response.code
p JSON.parse(response.body)
