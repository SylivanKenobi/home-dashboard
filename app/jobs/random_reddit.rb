require 'net/http'
require 'json'


id = "aww"

SCHEDULER.every '15m', :first_in => 0 do
   send_event(id, image: get_post)
end

def get_post
    subreddit = 'itookapicture'
    placeholder = '/assets/sunset.png'
    url = "https://www.reddit.com/r/#{subreddit}/hot.json?limit=100"

    response = RestClient::Request.execute(
        method: :get, url: url
      )
    json = JSON.parse(response.body)
    if json['data']['children'].count <= 0
      return placeholder
    else
      urls = json['data']['children'].map{|child| child['data']['url'] }

      # Ensure we're linking directly to an image, not a gallery etc.
      valid_urls = urls.select{|url| url.downcase.end_with?('png', 'gif', 'jpg', 'jpeg')}
      return "background-image:url(#{valid_urls.sample(1).first})"
    end
end