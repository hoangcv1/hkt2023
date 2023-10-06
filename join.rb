require_relative "api"
require 'json'
require 'dotenv'
Dotenv.load('.env')

include Api

response = Api::join(ENV["#{ENV['SELECTED_BOT']}_TOKEN"], ENV['SELECTED_BOARD'].to_i)

if response.code == "200"
  p "Join success"
else
  p "Join failed #{response.code}"
  p "#{response.body}"
end
