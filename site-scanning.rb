require 'csv'
require 'open-uri'
require 'pry'

# url = "https://api.gsa.gov/technology/site-scanning/data/weekly-snapshot.csv"

# string = URI.open(url).read

# cached_file = File.open("cached_site_scanning.csv", "w") do |f|
#     f << string
# end

# binding.pry

# Define the input and output file paths
input_file = 'cached_site_scanning.csv'
output_file = 'new_file.csv'
target_organization = 'General Services Administration'

# Read the CSV file and filter the rows
filtered_rows = []

CSV.foreach(input_file, headers: true) do |row|
  if row['target_url_agency_owner'] == target_organization
    filtered_rows << row
  end
end

# Write the filtered rows to the new CSV file
CSV.open(output_file, 'w') do |csv|
  # Write the headers
  csv << filtered_rows.first.headers if filtered_rows.any?

  # Write the filtered rows
  filtered_rows.each do |row|
    csv << row
  end
end

puts "Filtered CSV file created at #{output_file}"









input_file = "/Users/ryanjwold/Downloads/touchpoints-websites-2024-07-30.csv"

CSV.foreach(input_file, headers: true) do |row|
  puts row
end
