require 'csv'

input_file = "/Users/ryanjwold/Downloads/touchpoints-websites-2024-07-30.csv"

# modified_touchpoints_url = if touchpoints_url.include("www") ? touchpoints_url.gsub("www", "") : "#www{}"

output_file = 'new_file.csv'
output_file = 'cached_site_scanning.csv'

site_scanning_rows = CSV.open(output_file, headers: true)
site_scanning_domains = site_scanning_rows.map { |r| r["target_url"] }


# loop
# if site_scanning_domains.include?(touchpoints_url) ||
#   site_scanning_domains.include?(modified_touchpoints_url)

# CSV.foreach(input_file, headers: true) do |row|
non_matches = []
non_matches2 = []
lines = CSV.open(input_file, headers: true).readlines
lines.each do |row|
    domain = row["domain"]
    modified_domain = domain.include?("www") ? domain.gsub("www", "") : "www.#{domain}"
    non_matches << row["domain"] unless site_scanning_domains.include?(row["domain"])
    non_matches2 << row["domain"] unless site_scanning_domains.include?(row["domain"]) ||
    site_scanning_domains.include?(modified_domain)
end;nil

puts non_matches
puts non_matches.size
puts non_matches2.size
puts non_matches - non_matches2