require 'json'
require 'csv'

# Define file paths
json_file_path = 'exported-forms.json'
csv_file_path = 'exported-forms.csv'

# Read the JSON file
json_data = JSON.parse(File.read(json_file_path))

# Check if JSON data is an array
unless json_data.is_a?(Array)
  raise "JSON data should be an array of objects."
end

# Open a CSV file for writing
CSV.open(csv_file_path, 'w') do |csv|
  # Write the header row (keys from the first object)
  csv << json_data.first.keys #- ["logo"]

  # Write each object's values
  json_data.each do |obj|
    csv << obj.values
  end
end

puts "CSV file created at: #{csv_file_path}"
