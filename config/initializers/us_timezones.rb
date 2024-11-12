US_TIMEZONES = [
  ActiveSupport::TimeZone["Eastern Time (US & Canada)"],
  ActiveSupport::TimeZone["Central Time (US & Canada)"],
  ActiveSupport::TimeZone["Mountain Time (US & Canada)"],
  ActiveSupport::TimeZone["Pacific Time (US & Canada)"],
  ActiveSupport::TimeZone["Hawaii"]
].collect { |zone| [zone, zone.name] }