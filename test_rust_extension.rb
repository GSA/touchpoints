#!/usr/bin/env ruby

# Test script for the Rust widget renderer extension
require_relative 'ext/widget_renderer/widget_renderer'

puts "Testing Rust Widget Renderer Extension"
puts "=" * 50

# Test data similar to what a Form would pass
test_form_data = {
  short_uuid: "abc12345",
  modal_button_text: "Give Feedback",
  element_selector: "#feedback-button",
  delivery_method: "modal",
  load_css: true,
  success_text_heading: "Thank you!",
  success_text: "Your feedback has been received.",
  suppress_submit_button: false,
  suppress_ui: false,
  kind: "custom",
  enable_turnstile: false,
  has_rich_text_questions: false,
  verify_csrf: true,
  prefix: "fba-"
}

begin
  puts "Calling WidgetRenderer.generate_js with test data..."
  result = WidgetRenderer.generate_js(test_form_data)
  puts "Success! Generated JavaScript:"
  puts "-" * 30
  puts result
  puts "-" * 30
  puts "Extension is working correctly!"
rescue => e
  puts "Error: #{e.message}"
  puts "Backtrace:"
  puts e.backtrace.join("\n")
end
