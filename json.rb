require 'open-uri'
require 'pry'
require 'json'
require 'csv'

def get_responses(form_id)
  number_of_pages = 1095

  all_responses = []

  (0..number_of_pages).each do |i|
    url = "https://api.gsa.gov/analytics/touchpoints/v1/forms/#{form_id}.json?API_KEY=NiukqLjhHNrV03p98QtGQO1yL89hgen1PhXrBvEG&page=#{i}&start_date=2018-01-01&size=2000"

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

def write_responses_as_csv(form_id)
  records = JSON.parse(File.open("all_responses-#{form_id}.json").read)

  CSV.open("responses-#{form_id}.csv", "w") do |csv|
    csv << records.first["attributes"].keys

    records.each do |r|
      csv << r["attributes"].values
    end
  end
end

form_id = "58f51d4d"
get_responses(form_id)
write_responses_as_csv(form_id)