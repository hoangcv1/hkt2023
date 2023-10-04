require 'uri'
require 'net/http'

HOST = 'https://api-zarena.zinza.com.vn/'
GET_BOARD = 'api/boards/'.freeze

module Api
  def get_board id
    send_request("#{HOST}#{GET_BOARD}#{id}")
  end

  def send_request endpoint, method = 'get', body = {}
    url = URI(endpoint)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    if method == 'get'
      response = Net::HTTP.get_response(url)
    else
      response = Net::HTTP.post_form(url, body)
    end

    response
  end
end
