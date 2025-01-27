require 'net/http'
require 'uri'

def check_csp(url)
  uri = URI.parse(url)
  response = Net::HTTP.get_response(uri)

  csp = response['content-security-policy']
  if csp
    puts "CSP Policy found:"
    puts csp
  else
    puts "No CSP Policy found for #{url}"
  end
end

# Example usage
# url = 'https://touchpoints.digital.gov'
url = 'https://www.gsa.gov'
check_csp(url)
