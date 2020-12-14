require 'net/http'
require 'json'
require 'pry'

id = "aare"


SCHEDULER.cron '*/5 5-23 * * *', :first_in => 0 do
  send_event(id, get_stats)
end

def get_stats
  stats = JSON.parse(URI.parse('https://aareguru.existenz.ch/v2018/current?city=bern&app=home-dashboard&version=1.0.42').read)
  {
    temp: stats['aare']['temperature'],
    temp_text: stats['aare']['temperature_text'],
    flow: stats['aare']['flow'],
    flow_text: stats['aare']['flow_text']
  }
end
