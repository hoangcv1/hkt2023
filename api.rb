require 'uri'
require 'net/http'

HOST = 'https://api-zarena.zinza.com.vn/'
GET_BOARD = 'api/boards/'.freeze
JOIN_BOARD = 'api/bots/'.freeze

module Api
  def get_board id
    send_request("#{HOST}#{GET_BOARD}#{id}")
  end

  def join bot_id, board_id
    send_request(join_api(bot_id), 'POST', {"boardId": board_id})
  end

  def move bot_id, direction
    send_request(move_api(bot_id), 'POST', {"direction": direction})
  end

  def send_request endpoint, method = 'get', body = {}
    url = URI(endpoint)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    if method == 'get'
      response = Net::HTTP.get_response(url)
    else
      headers = { 'Content-Type': 'application/json' }
      start_time = Time.now
      response = Net::HTTP.post(url, body.to_json, headers)
      p "Response code: #{response.code}. Time now: #{Time.now.strftime("%H:%M:%S.%L")} Time spent: #{Time.now - start_time}"
    end

    response
  end

  def handle_game_objects game_objects
    all_coins = []
    all_bots = []
    all_gates = []

    game_objects.each do |obj|
      if obj['type'] == 'CoinGameObject'
        all_coins << Coin.new(**obj)
      end

      if obj['type'] == 'BotGameObject'
        all_bots << BotGame.new(**obj)
      end

      if obj['type'] == 'GateGameObject'
        all_gates << obj['position']
      end
    end

    [all_coins, all_bots, all_gates]
  end

  private

  def join_api bot_id
    "#{HOST}#{JOIN_BOARD}#{bot_id}/join"
  end

  def move_api bot_id
    "#{HOST}#{JOIN_BOARD}#{bot_id}/move"
  end
end
