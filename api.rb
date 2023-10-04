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
    send_request("#{HOST}#{JOIN_BOARD}#{bot_id}/join", 'POST', {"boardId": board_id})
  end

  def move bot_id, direction
    send_request("#{HOST}#{JOIN_BOARD}#{bot_id}/move", 'POST', {"direction": direction})
  end

  def send_request endpoint, method = 'get', body = {}
    url = URI(endpoint)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    if method == 'get'
      response = Net::HTTP.get_response(url)
    else
      headers = { 'Content-Type': 'application/json' }
      response = Net::HTTP.post(url, body.to_json, headers)
    end

    response
  end
end
