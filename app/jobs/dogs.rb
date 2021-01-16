require 'net/http'
require 'json'
require 'pry'

require_relative '../lib/secrets'

id = "dog"


SCHEDULER.cron '*/5 5-23 * * *', :first_in => 0 do
  send_event(id, get_doggo_image)
end

def get_doggo_image
  url = ['thecatapi','thedogapi'].sample
  uri = URI.parse("https://api.#{url}.com/v1/images/search")
  request = Net::HTTP::Get.new(uri)
  request['x-api-key'] = Secrets.get('DOGGO_KEY')
  response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) {|http|
    http.request(request)
  }
  data = JSON.parse(response.body)[0]
  breeds = data['breeds'][0]
  animal = url.eql?('thecatapi') ? 'kitten' : 'doggo'

  if !breeds.nil?
    name = breeds.key?('name') ? breeds['name'] : "Good #{animal}"
    size = breeds.key?('height') ? breeds['height']['metric'] : 'many'
    weight = breeds.key?('weight') ? breeds['weight']['metric']: 'chonk'
    life_span = breeds.key?('life_span') ? breeds['life_span'] : 'forever'
    { image: data['url'],
      name: name,
      size: size,
      weight: weight,
      life_span: life_span }
  else
    { image: data['url'],
      name: "Good #{animal}",
      size: 'many',
      weight: 'chonk',
      life_span: 'forever' }
  end
end
