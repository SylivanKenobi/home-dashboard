require 'net/http'
require 'json'
require 'pry'

id = "dog"


SCHEDULER.every '30s', :first_in => 0 do |job|
  send_event(id, { image: get_doggo_image })
end

def get_doggo_image
  uri = URI.parse('https://api.thedogapi.com/v1/images/search')

  request = Net::HTTP::Get.new(uri)
  request['x-api-key'] = ENV['DOGGO_KEY']

  response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') {|http|
    http.request(request)
  }
end
