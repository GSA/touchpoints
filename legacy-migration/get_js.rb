require 'net/http'
require 'uri'

# Define the list of values
values = [
 "bd6ba048",
 "b892a4cd",
 "875f2258",
 "1da90d6b",
 "2eea207c",
 "46af3008",
 "dd0863f3",
 "09e9af92",
 "1fcd3ee7",
 "ea2c327c",
 "51fb247c",
 "b5e39685",
 "ad8cde54",
 "09a858a1",
 "b5786a3e",
 "bc9f849d",
 "776439e8",
 "984fb750",
 "b34abac6",
 "01d45aa1",
 "87ea9d74",
 "ccf6b6da",
 "e1ff2558",
 "20cb68a5",
 "b4755156",
 "879a4bf4",
 "0849eb5c",
 "5a03771d",
 "2093cc9d",
 "7a158f1a",
 "587c78d9",
 "c7b6655b",
 "165a8c5d",
 "41ac94a1",
 "8e6a3bbe",
 "ad3f5163",
 "72375556",
 "703d4786",
 "846c7e15",
 "32086166",
 "d6130652",
 "afcf78ed",
 "afdd1804",
 "6bda9887",
 "6b42c95a",
 "7e9a15f5",
 "bd0aaff1",
 "7954cfb7",
 "2fa62273",
 "e53cdf37",
 "8118b454",
 "236b5c57",
 "b94b09c3",
 "1c5603ef",
 "a4de5274",
 "a55e183b",
 "bbefa46f",
 "d3215f65",
 "44da21fd",
 "defb5247",
 "a70a585a",
 "dd4dd58d",
 "4fd87c87",
 "5faa0c9e",
 "01e6ca60",
 "fb4b4341",
 "0e46b25a",
 "31b5be9c",
 "c64cd47e",
 "dca70910",
 "4821d816",
 "73028683",
 "75e3e563",
 "c5711b18",
 "a02ad761",
 "035ab288",
 "0834fb80",
 "ddca50c3",
 "3f413f75",
 "c9c95b24",
 "37db63db",
 "5fe1d90a",
 "e0796705",
 "ca96d371",
 "22cab0a7",
 "f3ad0716",
 "b173a0fe",
 "d412cbeb",
 "ad58fba7",
 "da1c1fad",
 "d78797fb",
 "e9853029",
 "ed4f53b7",
 "f3dfedf3",
 "82738930",
 "f26ffc87",
 "cf47d10a",
 "515c4dab",
 "d586852b",
 "71837744",
 "57773e4a",
 "b0fcfb24",
 "8945240e",
 "14c81d67",
 "792d835f",
 "d293d96c",
 "9a4f5781",
 "eb210f36",
 "8cc54883",
 "3c345ea9",
 "0f2f7bee",
 "1c195397",
 "471aab3e",
 "4a738b0f",
 "b05ce584"
]

# Base URL template with interpolation placeholder
base_url = "https://touchpoints-demo.app.cloud.gov/touchpoints/%{value}.js"

values.each do |value|
  # Interpolate the value into the URL
  url = base_url % { value: value }

  # Parse the URL
  uri = URI.parse(url)

  # Make the HTTP GET request
  response = Net::HTTP.get_response(uri)

  # Check if the request was successful
  if response.is_a?(Net::HTTPSuccess)
    # Define the file name and write the response body to the file
    file_name = "#{value}.txt"
    File.open(file_name, "w") do |file|
      file.write(response.body)
    end
    puts "Successfully wrote data to #{file_name}"
  else
    puts "Failed to fetch data for #{value}: #{response.message}"
  end
end
