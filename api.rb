require 'open-uri'
require 'pry'
require 'json'
require 'csv'

def get_responses(form_id)
  number_of_pages = 5

  all_responses = []

  (0..number_of_pages).each do |i|
    url = "https://api.gsa.gov/analytics/touchpoints/v1/forms/#{form_id}.json?API_KEY=GTanZOFHw4ilAiAXtnPkHOLyfEcnmww9GabQwinn&page=#{i}&size=2000&start_date=2018-01-01"

    puts "Getting #{url}..."
    json = JSON.parse(URI.open(url).read)
    next unless json["included"]
    responses = json["included"]

    all_responses += responses
  end

  File.open("all_responses-#{form_id}.json", "w") do |f|
    f << all_responses.to_json
  end
end

def get_digital_service_accounts
  all_responses = []

  (0..70).each do |i|
    url = "https://api.gsa.gov/analytics/touchpoints/v1/digital_service_accounts.json?API_KEY=GTanZOFHw4ilAiAXtnPkHOLyfEcnmww9GabQwinn&page=#{i}"

    puts "Getting #{url}..."
    json = JSON.parse(URI.open(url).read)
    responses = json["data"]
    next unless responses
    all_responses += responses.collect { |r|
      z = r["attributes"]
      z["id"] = r["id"]
      z
    }
  end


  File.open("dsa.json", "w") do |f|
    f << all_responses.to_json
  end

  CSV.open("dsa.csv", "w") do |csv|
    csv << all_responses.first.keys

    all_responses.each do |r|
      csv << r.values
    end
  end
end

def write_responses_as_csv(form_id)
  records = JSON.parse(File.open("all_responses-#{form_id}.json").read)

  CSV.open("responses-#{form_id}.csv", "w") do |csv|
    csv << records.first["attributes"].keys

    records.each do |r|
      csv << r["attributes"].values
    end
  end
end

## DO SOME THINGS...

#### grab form responses
form_id = "b6ee6204"
get_responses(form_id)
write_responses_as_csv(form_id)

##### grab digital services accounts
# get_digital_service_accounts