require "net/http"
require "json"

todoist_token = 'YOUR_TODOIST_TOKEN_HERE'

SCHEDULER.every '3m' do
    uri = URI.parse("https://todoist.com/API/v7/completed/get_stats?token=#{todoist_token}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
     
    if response.code == "200"
      result = JSON.parse(response.body)
      send_event('todoist_completed', { current: result["days_items"][0]["total_completed"] })
    end
end