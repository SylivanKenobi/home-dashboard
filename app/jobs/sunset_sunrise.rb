require 'net/http'
require 'json'
require 'pry'
require 'rest-client'

require_relative '../lib/secrets'

id = "sun"

SCHEDULER.every '1h', :first_in => 0 do
  send_event(id, get_sun)
end

def get_sun
  if token_expired?
    @bearer_token = get_token['access_token']
  end
  latitude = 47.001153
  longitude = 7.462337
  # Location Zollikofen Bahnhof
  url = "https://api.sunrise-sunset.org/json?lat=#{latitude}&lng=#{longitude}&formatted=0"
  response = RestClient::Request.execute(
      method: :get, url: url,
    )
  json = JSON.parse(response.body)['results']
  sunset = Time.iso8601(json['sunset']) + 3600
  sunrise = Time.iso8601(json['sunrise']) + 3600
  day_length = json['day_length'] / 3600
  return { sunset: sunset.strftime("%H:%M"), sunrise: sunrise.strftime("%H:%M"), day_length: day_length }
end
