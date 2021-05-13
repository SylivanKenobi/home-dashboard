require 'net/http'
require 'json'
require 'pry'
require 'rest-client'

require_relative '../lib/secrets'

day_id = "day_weather"
week_id = "week_weather"
sun_id = "sun"


SCHEDULER.cron '5 0 * * *', :first_in => 0 do
  pp 'get_data'
  @data = get_data
  pp 'send data'
  send_event(week_id, { items: seven_day_weather(@data) })
  dw = day_weather(@data)
  send_event(day_id, dw[:weather])
  send_event(sun_id, dw[:sun])
  pp 'done'
end

SCHEDULER.cron '1 */1 * * *' do
  pp 'send data'
  send_event(week_id, { items: seven_day_weather(@data) })
  dw = day_weather(@data)
  send_event(day_id, dw[:weather])
  send_event(sun_id, dw[:sun])
  pp 'done'
end

def get_data
  if token_expired?
    @bearer_token = get_token['access_token']
  end

  # Location Zollikofen Bahnhof
  url = 'https://api.srgssr.ch/srf-meteo/forecast/46.9962,7.4525'
  response = RestClient::Request.execute(
      method: :get, url: url, headers: { Authorization: "Bearer #{@bearer_token}" }
    )
  JSON.parse(response.body)
end

def day_weather(data)
  forecast = data['forecast']
  time_now = Time.now.getlocal('+02:00')
  hour = forecast['60minutes'].find  do |hour|
    timestamp = Time.parse(hour['local_date_time'])
    timestamp.strftime('%H').to_i == time_now.strftime("%H").to_i && timestamp.strftime('%d') == time_now.strftime("%d")
  end
  day = forecast['day'].find  do |day|
    timestamp = Time.parse(day['local_date_time'])
    timestamp.strftime('%d') == time_now.strftime("%d")
  end
  {
    sun: {
      sunset: day['SUNSET'].to_s.insert(-3, ':'),
      sunrise: day['SUNRISE'].to_s.insert(-3, ':'),
      sunhours: day['SUN_H'].to_s
    },
    weather: {
      max_tmp_day: day['TX_C'],
      min_tmp_day: day['TN_C'],
      rain_prob_day: day['PROBPCP_PERCENT'],
      rain_mm_day: day['RRR_MM'],
      wind_speed_day: day['FF_KMH'],
      wind_max_speed_day: day['FX_KMH'],
      current_temp: hour['TTT_C'],
      rain_prob_hour: hour['PROBPCP_PERCENT'],
      rain_mm_hour: hour['RRR_MM'],
      wind_speed_hour: hour['FF_KMH'],
      wind_max_speed_hour: hour['FX_KMH']
    }
  }
end

def seven_day_weather(data)
  weather = []
  data['forecast']['day'].each do |day|
    weather_code = day['SYMBOL_CODE']
    week_day = DateTime.parse(day['local_date_time']).to_date.strftime("%A")
    weather << {
      day: week_day,
      min_temp: day['TN_C'],
      max_temp: day['TX_C'],
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
