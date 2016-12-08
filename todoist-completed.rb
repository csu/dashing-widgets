require "net/http"
require "json"

todoist_token = 'YOUR_TODOIST_TOKEN_HERE'

SCHEDULER.every '3m' do
    http = Net::HTTP.new("todoist.com", 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request = Net::HTTP::Get.new("/API/v7/completed/get_stats?token=#{todoist_token}")
    response = http.request(request)
     
    if response.code == "200"
      result = JSON.parse(response.body)
      send_event('todoist_completed', { current: result["days_items"][0]["total_completed"] })
    end
end