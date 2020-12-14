require 'net/http'
require 'json'
require 'pry'

require_relative '../lib/secrets'

id = "slideshow"


# SCHEDULER.every '15m', :first_in => 0 do
#   send_event(id, image: random_image)
# end

def random_image
  images = Dir["assets/images/slideshow/*"]
  images[rand(images.length)].gsub(/\/images/,"")
end
