require_relative "api"
require 'json'
require 'dotenv'
Dotenv.load('.env')

include Api

DIRECTION = %w[UP DOWN LEFT RIGHT]
START_TIME = Time.now

while (Time.now - START_TIME) < 300
  5.times do |i|
    response = Api::move(ENV["BOT_1_ID"], DIRECTION.sample)
    p "Moved"
    sleep 0.8
  end
end
