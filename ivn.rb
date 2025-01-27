require 'csv'
require 'pry'

# create holders for the 4 types of objects
sources = []
components = []
source_to_component_links = []
component_links = []

# open the existing IVN data
table = CSV.open("ivn.csv", headers: true).read

# loop through the data and extract the 4 types of objects
table.each do |row|
  enabling_source = row[0]
  enabling_source_url = row[7]
  enabling_source_agency = row[9]

  enabling_component = row[1]
  enabling_component_description = row[2]

  dependent_component = row[3]
  dependent_component_description = row[4]

  dependent_source = row[5]
  dependent_source_url = row[8]
  dependent_source_agency = row[10]

  # Linkage mandated by what US Code or OMB policy? = row[6]

  # Build an array for each of the objects
  sources << enabling_source
  sources << dependent_source

  components << enabling_component
  components << dependent_component
end

puts "Original sources count #{sources.size}"
puts "Original components count #{components.size}"

# make the sources and components unique
sources.uniq!.compact
components.uniq!.compact

# assign IDs to the Sources
unique_sources = []
sources.each_with_index do |source, i|
  unique_sources << {
    source => i
  }
end

# assign IDs to the Components
id_components = []
components.each_with_index do |component, i|
  id_components << {
    i => component
  }
end

puts "Unique sources count #{unique_sources.size}"
puts "Unique components count #{id_components.size}"


structured_sources = []
structured_components = []


puts "Structured sources count #{structured_sources.size}"
