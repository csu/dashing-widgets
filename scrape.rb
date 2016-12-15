require 'nokogiri'
require 'open-uri'

scrape_interval = '30s'

# format: {
#  event_name: {
#    url: "url",
#    search: "search"
#  }
#}
scrape_rules = {
    my_name: {
      url: "https://christopher.su",
      search: ".home-name"
    }
}

SCHEDULER.every scrape_interval do
    scrape_rules.each do |event_name, rule|
      doc = Nokogiri::HTML(open(rule[:url]))

      doc.css(rule[:search]).each do |res|
        send_event("scrape_" + event_name.to_s.downcase, { text: res.content })
      end
    end
end