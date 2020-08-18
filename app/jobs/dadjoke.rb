require 'net/http'
require 'json'
require 'pry'
require 'rest-client'

require_relative '../lib/secrets'

id = "dad"

SCHEDULER.every '15m', :first_in => 0 do
  send_event(id, text: get_dad_joke)
end

def get_dad_joke
  response = RestClient::Request.execute(
      method: :get, url: 'https://icanhazdadjoke.com/', headers: { Accept: "text/plain" }
    )
  response.body
end
