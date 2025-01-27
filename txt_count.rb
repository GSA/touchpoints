# Directory containing the text files
directory = "legacy-migration"

# Get a list of all text files in the directory
files = Dir.glob(File.join(directory, '*.txt'))

# Create a hash to store the filename and line count
file_line_counts = {}

# Loop through each file and count the number of lines
files.each do |file|
  line_count = File.foreach(file).count
  file_line_counts[file] = line_count
end

# Sort the files by line count in descending order and take the top 10
top_10_files = file_line_counts.sort_by { |_, line_count| -line_count }.first(10)

# Print the filenames of the top 10 files
top_10_files.each do |file, line_count|
  puts "#{File.basename(file)}: #{line_count} lines"
end
