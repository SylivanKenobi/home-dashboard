require 'net/http'
require 'json'
require 'pry'

id = "dog"


SCHEDULER.cron '*/5 5-23 * * *', :first_in => 0 do
  send_event(id, get_doggo_image)
end

def get_doggo_image
  uri = URI.parse('https://api.thedogapi.com/v1/images/search')
  request = Net::HTTP::Get.new(uri)
  request['x-api-key'] = ENV['DOGGO_KEY']
  response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) {|http|
    http.request(request)
  }
  data = JSON.parse(response.body)[0]
  breeds = data['breeds'][0]
  if !breeds.nil?
    { image: data['url'],
      name: breeds['name'],
      size: breeds['height']['metric'],
      weight: breeds['weight']['metric'],
      life_span: breeds['life_span'] }
  else
    { image: data['url'],
      name: 'Good doggo',
      size: 'many',
      weight: 'chonk',
      life_span: 'forever' }
  end
end
