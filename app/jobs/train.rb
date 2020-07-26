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
      vehicle: connection['legs'][0]['number'].split(" ")[0],
      duration: connection['duration']/60,
      track: connection["legs"][0]["track"]
    }
  end
  parsed_connections
end

# => {"from"=>"Zollikofen",
#  "departure"=>"2020-07-26 16:31:00",
#  "to"=>"Bern, Hauptbahnhof",
#  "arrival"=>"2020-07-26 16:46:00",
#  "duration"=>900,
#  "disruptions"=>
#   {"http://fahrplan.sbb.ch/bin/help.exe/de?tpl=showmap_external&messageID=1085100&mti=1&hMap=false#hfsShm"=>
#     {"id"=>"1085100",
#      "header"=>"Bern: Eingeschränkter Zugang zu Gleis 13 vom 27.01.2020 bis 02.11.2020",
#      "lead"=>"Bis Anfang November 2020 stehen Reisenden via Gleis 13 am Bahnhof Bern nicht alle Auf- und Abgänge zum Perron zur Verfügung.",
#      "text"=>
#       "Bis Anfang November 2020 stehen Reisenden via Gleis 13 am Bahnhof Bern nicht alle Auf- und Abgänge zum Perron zur Verfügung.<br /><br />Zudem ist der Lift zwischen der Welle und dem Perron Gleis 12/13 vom 15. Juni bis 31. Juli 2020 ausser Betrieb.<p>Weitere Informationen:<br /> <a href=\"https://company.sbb.ch/de/ueber-die-sbb/projekte/projekte-mittelland-tessin/bahnknoten-bern.html?tracking-marketingurl=bern\">Info Bern</a><br /> </p> ",
#      "timerange"=>"27.01.2020 00:00 - 02.11.2020 23:59",
#      "exact"=>false,
#      "priority"=>60}},
#  "legs"=>
#   [{"departure"=>"2020-07-26 16:31:00",
#     "tripid"=>"T2020_015458_000033_102_beaf60b_0",
#     "number"=>"S4 15458",
#     "stopid"=>"8504410",
#     "x"=>601847,
#     "y"=>205641,
#     "name"=>"Zollikofen",
#     "sbb_name"=>"Zollikofen",
#     "type"=>"strain",
#     "line"=>"S4",
#     "terminal"=>"Thun",
#     "fgcolor"=>"fff",
#     "bgcolor"=>"039",
#     "*G"=>"S",
#     "*L"=>"4",
#     "operator"=>"BLS-bls",
#     "stops"=>[{"arrival"=>"2020-07-26 16:35:00", "departure"=>"2020-07-26 16:35:00", "name"=>"Bern Wankdorf", "stopid"=>"8516161", "x"=>602043, "y"=>201862, "lon"=>7.465483, "lat"=>46.967827}],
#     "runningtime"=>540,
#     "exit"=>{"arrival"=>"2020-07-26 16:40:00", "stopid"=>"8507000", "x"=>600038, "y"=>199750, "name"=>"Bern", "sbb_name"=>"Bern", "track"=>"5", "lon"=>7.439136, "lat"=>46.948832},
#     "track"=>"3",
#     "attributes"=>{"1_1.1_OM"=>"Maskenpflicht für Reisende ab 12 Jahren"},
#     "disruptions"=>
#      {"http://fahrplan.sbb.ch/bin/help.exe/de?tpl=showmap_external&messageID=1085100&mti=1&hMap=false#hfsShm"=>
#        {"id"=>"1085100",
#         "header"=>"Bern: Eingeschränkter Zugang zu Gleis 13 vom 27.01.2020 bis 02.11.2020",
#         "lead"=>"Bis Anfang November 2020 stehen Reisenden via Gleis 13 am Bahnhof Bern nicht alle Auf- und Abgänge zum Perron zur Verfügung.",
#         "text"=>
#          "Bis Anfang November 2020 stehen Reisenden via Gleis 13 am Bahnhof Bern nicht alle Auf- und Abgänge zum Perron zur Verfügung.<br /><br />Zudem ist der Lift zwischen der Welle und dem Perron Gleis 12/13 vom 15. Juni bis 31. Juli 2020 ausser Betrieb.<p>Weitere Informationen:<br /> <a href=\"https://company.sbb.ch/de/ueber-die-sbb/projekte/projekte-mittelland-tessin/bahnknoten-bern.html?tracking-marketingurl=bern\">Info Bern</a><br /> </p> ",
#         "timerange"=>"27.01.2020 00:00 - 02.11.2020 23:59",
#         "exact"=>false,
#         "priority"=>60}},
#     "type_name"=>"S-Bahn",
#     "lon"=>7.462922,
#     "lat"=>47.00182},
#    {"arrival"=>"2020-07-26 16:40:00",
#     "stopid"=>"8507000",
#     "x"=>600038,
#     "y"=>199750,
#     "name"=>"Bern",
#     "sbb_name"=>"Bern",
#     "normal_time"=>0,
#     "stops"=>nil,
#     "type"=>"walk",
#     "departure"=>"2020-07-26 16:40:00",
#     "runningtime"=>360,
#     "exit"=>{"arrival"=>"2020-07-26 16:46:00", "x"=>"599992", "y"=>"199768", "isaddress"=>false, "name"=>"Bern, Hauptbahnhof", "sbb_name"=>"Bern, Hauptbahnhof", "stopid"=>"8507785", "lon"=>7.438532, "lat"=>46.948994},
#     "type_name"=>"Fussweg",
#     "lon"=>7.439136,
#     "lat"=>46.948832},
#    {"arrival"=>"2020-07-26 16:46:00", "x"=>"599992", "y"=>"199768", "isaddress"=>false, "name"=>"Bern, Hauptbahnhof", "sbb_name"=>"Bern, Hauptbahnhof", "stopid"=>"8507785", "lon"=>7.438532, "lat"=>46.948994}]}
