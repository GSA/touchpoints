require 'csv'
require 'json'
require 'open-uri'
require 'pry'

$API_KEY = "NiukqLjhHNrV03p98QtGQO1yL89hgen1PhXrBvEG"
@form_id = "58f51d4d"

def filename(start_page, end_page)
  "form-#{@form_id}-#{start_page}-#{end_page}.json"
end

def filename2(start_page, end_page)
    filename2 = "submissions-#{@form_id}-#{start_page}-#{end_page}.json"
end

def get_responses(start_page, end_page)
  form_responses = []
  submission_responses = []

  (start_page..end_page).each do |i|
    url = "https://api.gsa.gov/analytics/touchpoints/v1/forms/#{@form_id}.json?API_KEY=#{$API_KEY}&page=#{i}&size=5000&&start_date=2016-01-01"

    puts "Getting #{url}..."
    # binding.pry
    json = JSON.parse(URI.open(url).read)

    # form_responses += json["data"]
    attrs = json["data"]["attributes"]
    attrs["id"] = json["id"]
    form_responses << attrs

    # filter the submissions out and write them to file
    submissions = json["included"]
    submission_responses += submissions
  end

  File.open(filename(start_page, end_page), "w") do |f|
    f << form_responses.to_json
  end

  File.open(filename2(start_page, end_page), "w") do |f|
    f << submission_responses.to_json
  end
end

def write_responses_as_csv(start_page, end_page)
  records = JSON.parse(File.open(filename(start_page, end_page)).read)

  CSV.open("responses-#{start_page}-#{end_page}.csv", "w") do |csv|
    csv << records.first.keys

    records.each do |r|
      csv << r.values
    end
  end
end

def write_submissions_as_csv(start_page, end_page)
    records = JSON.parse(File.open(filename2(start_page, end_page)).read)

    CSV.open("submissions-#{start_page}-#{end_page}.csv", "w") do |csv|
        headers = ["id"] + records.first["attributes"].keys
        csv << headers

        records.each do |r|
            submission = [r["id"]] + r["attributes"].values
            csv << submission
        end
    end
end

# start_page = 0
# end_page = 199

# start_page = 200
# end_page = 299

# start_page = 300
# end_page = 399

start_page = 400
end_page = 420

#start_page = 600
# end_page = 706


start_page = 400
start_page = 700

while start_page < 706

end_page = start_page + 20

get_responses(start_page, end_page)
write_responses_as_csv(start_page, end_page)
write_submissions_as_csv(start_page, end_page)

start_page = end_page + 1
end