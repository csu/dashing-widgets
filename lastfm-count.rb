require "net/http"
require "json"
require "date"

lastfm_api_key = 'YOUR_LASTFM_API_KEY_HERE'

SCHEDULER.every '30s' do
    today = Date.today.to_time.utc.to_i
    tomorrow = today + 24*60*60
    
    uri = URI.parse("http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=christophersu&api_key=#{lastfm_api_key}&format=json&limit=200&from=#{today}&to=#{tomorrow}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
     
    if response.code == "200"
      result = JSON.parse(response.body)
      send_event('lastfm_count', { current: Integer(result["recenttracks"]["@attr"]["total"]) })
    end
end