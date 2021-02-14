require 'net/http'
require 'json'
require 'pry'
require 'time'

id = "train"


SCHEDULER.cron '*/5 5-23 * * *', :first_in => 0 do
  send_event(id, { items: get_timetable })
end

def get_timetable
  data = JSON.parse(URI.parse('https://timetable.search.ch/api/route.json?from=Zollikofen+Bahnhof&to=Bern+Hauptbahnhof').read)
  connections = data['connections']
  parsed_connections = []
  connections.each do |connection|
    parsed_connections << {
      departure: Time.parse(connection['departure']).strftime("%H:%M"),
      vehicle: connection['legs'][0]['line'],
      duration: connection['duration']/60,
      track: connection["legs"][0]["track"]
    }
  end
  parsed_connections
end
