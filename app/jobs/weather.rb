require 'net/http'
require 'json'
require 'pry'
require 'rest-client'

require_relative '../lib/secrets'

id = "weather"

SCHEDULER.cron '*/5 5-23 * * *', :first_in => 0 do
  send_event(id, { items: seven_day_weather })
end

def seven_day_weather
  if token_expired?
    @bearer_token = get_token['access_token']
  end

  # Location Zollikofen Bahnhof
  url = 'https://api.srgssr.ch/forecasts/v1.0/weather/7day?latitude=47.001153&longitude=7.462337'
  response = RestClient::Request.execute(
      method: :get, url: url, headers: { Authorization: "Bearer #{@bearer_token}" }
    )
  json = JSON.parse(response.body)
  weather = []
  json['7days'].each do |day|
    weather_code = day['values'][1]['smbd']
    a = day['formatted_date'].split(".")
    d = DateTime.new(a[2].to_i, a[1].to_i, a[0].to_i)
    weather << {
      day: d.strftime("%A"),
      min_temp: day['values'][0]['ttn'].to_i,
      max_temp: day['values'][2]['ttx'].to_i,
      weather_img: "assets/weather-symbols/#{weather_code}.png",
      weather_text: get_weather_text(weather_code)
    }
  end
  weather
end

def get_weather_text(code)
  yaml = File.open('assets/data/code-mapping.yaml') { |file| YAML.safe_load(file) }
  yaml[code.to_i]['long-german']
end

def get_token
  encoded_token = Base64.strict_encode64("#{Secrets.get('SRG_API_KEY')}:#{Secrets.get('SRG_API_SECRET')}")
  token_url = 'https://api.srgssr.ch/oauth/v1/accesstoken?grant_type=client_credentials'
  response = RestClient::Request.execute(
      method: :post, url: token_url, headers: { Authorization: "Basic #{encoded_token}" }
    )
  @token_response = JSON.parse(response.body)
end

def token_expired?
  @bearer_token.nil? || Time.at(@token_response['issued_at'].to_i + @token_response['expires_in'].to_i) < Time.now
end
