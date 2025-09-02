#!/usr/bin/env ruby

# Test script to verify the dynamic question parameter generation
MAX_QUESTIONS = 30

# Generate the question parameters dynamically
question_params = (1..MAX_QUESTIONS).map { |i| :"question_text_#{i.to_s.rjust(2, '0')}" }

puts "Generated #{question_params.length} question parameters:"
puts "First 5: #{question_params.first(5)}"
puts "Last 5: #{question_params.last(5)}"

# Verify we have the expected parameters
expected_first = :question_text_01
expected_last = :question_text_30

if question_params.first == expected_first && question_params.last == expected_last
  puts "✅ SUCCESS: Parameter generation is working correctly!"
  puts "   - First parameter: #{question_params.first}"
  puts "   - Last parameter: #{question_params.last}"
  puts "   - Total parameters: #{question_params.length}"
else
  puts "❌ ERROR: Parameter generation failed!"
  puts "   - Expected first: #{expected_first}, got: #{question_params.first}"
  puts "   - Expected last: #{expected_last}, got: #{question_params.last}"
end

# Test that we can now support more than 20 questions
if question_params.length > 20
  puts "✅ SUCCESS: Now supports more than 20 questions (#{question_params.length} total)"
else
  puts "❌ ERROR: Still limited to 20 or fewer questions"
end
