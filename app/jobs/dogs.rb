require 'net/http'
require 'json'
require 'pry'

id = "dog"


SCHEDULER.every '30s', :first_in => 0 do |job|
  image_url = JSON.parse(URI.parse("https://dog.ceo/api/breed/#{breed}/images/random").read)['message']
  send_event(id, { image: image_url })
end

def breeds
  @breeds ||= get_breeds
end

def get_breeds
  JSON.parse(URI.parse("https://dog.ceo/api/breeds/list/all").read)
end

def breed
  breeds['message'].to_a[rand(breeds['message'].length)][0]
end
