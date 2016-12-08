require "net/http"
require "json"

stock_symbols = [
  "BND"
]

SCHEDULER.every '1m', :first_in => 0 do |job|

  stocks_str = stock_symbols.map{ |e| "\"#{e}\"" }.join(',').upcase
  uri = URI.parse("http://query.yahooapis.com/v1/public/yql?q=select * from yahoo.finance.quotes where symbol IN (#{stocks_str})&format=json&env=http://datatables.org/alltables.env")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)

  if response.code != "200"
    puts "request failed with #{response.code})\n\n#{response.body}"
  else
    results = JSON.parse(response.body)["query"]["results"]["quote"]

    quotes = Array.new

    results.each do |result|
      stock_name = result["Name"]
      symbol = result["Symbol"]
      price = result["Ask"]
      change = result["PercentChange"]

      # emit individual quote as Number
      send_event("stock_" + symbol.gsub(/[^A-Za-z0-9]+/, '_').downcase, {
        current: price,
        moreinfo: change})

      # emit all quotes as List
      quotes.push({
        label: symbol,
        value: change
      })
    end

    send_event("stock_all", { items: quotes })
  end
end