require 'net/http'
require 'json'

SCHEDULER.every '15m', :first_in => 0 do
   send_event("picture", image: get_post({itookapicture: 75, analog: 75}))
   send_event("bike", image: get_post({Bikeporn: 150, mountainbiking: 150, FixedGearBicycle: 100}))
end

def get_post(subreddits)
    urls = []

    subreddits.each do |subreddit, posts|
      url = "https://www.reddit.com/r/#{subreddit}/hot.json?limit=#{posts}"
      response = RestClient::Request.execute( method: :get, url: url )
      json = JSON.parse(response.body)
      urls = urls + json['data']['children'].map{ |child| child['data']['url'] }
    end

    valid_urls = urls.select{|url| url.downcase.end_with?('png', 'gif', 'jpg', 'jpeg')}
    return "background-image:url(#{valid_urls.sample})"
end
