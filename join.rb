require_relative "api"
require 'json'
require 'dotenv'
Dotenv.load('.env')

include Api

response = Api::join(ENV["#{ENV['SELECTED_BOT']}"], 1)

p response.code
p JSON.parse(response.body)
