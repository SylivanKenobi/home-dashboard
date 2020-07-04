# https://api.srgssr.ch/forecasts/v1.0/weather/7day

require 'net/http'
require 'json'
require 'pry'

id = "weather"


# SCHEDULER.every '10m', :first_in => 0 do |job|
#   binding.pry
#   send_event(id, { image: image_url })
# end

def get_token
  uri = URI.parse('https://api.srgssr.ch/oauth/v1/accesstoken?grant_type=client_credentials')

  request = Net::HTTP::Post.new(uri)
  request['authorization'] = "Basic"

  Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') {|http|
    http.request(request)
  }
end
