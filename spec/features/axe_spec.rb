# frozen_string_literal: true
return true
require 'rails_helper'

def urls
  base_url = "https://touchpoints.digital.gov"
  base_url = "https://www.challenge.gov"
  base_url = "https://www.challenge.gov"
  # base_url = "https://www.usace.army.mil/DesktopModules/SiteData/SiteMap.ashx"

  # sitemap_url = "#{base_url}/sitemap.xml"
  # sitemap_url = "https://www.usace.army.mil/DesktopModules/SiteData/SiteMap.ashx"
  sitemap_url = "https://www.usace.army.mil/afpims-sitemap.aspx"
  sitemap_xml = URI.open(sitemap_url).read

  # Parse the XML
  doc = Nokogiri::XML(sitemap_xml)

  arr = []

  doc.css("url").each do |url_node|
    location = url_node.css("loc").text
    lastmod = url_node.css("lastmod").text
    # lastmod = url_node.at('lastmod')&.text
    puts "URL: #{location}"
    puts "Last modified: #{lastmod}" if lastmod
    puts "-" * 30
    arr << location
  end
  arr
end

def generate_filepath_from_url(url, extension = '.json')
  # Parse the URL to extract the host and path
  uri = URI.parse(url)

  # Replace non-alphanumeric characters with underscores
  sanitized_host = uri.host.gsub(/[^0-9a-z]/i, '_')
  sanitized_path = uri.path.gsub(/[^0-9a-z]/i, '_')

  # Combine host and path, and append the desired file extension
  filepath = "#{sanitized_host}#{sanitized_path}".gsub(/_+/, '_').sub(/_$/, '')

  # Add the file extension (default is .json)
  "#{filepath}#{extension}"
end


feature 'AXE sitemap scan', js: true do
  urls.each do |url|
    describe "Scanning #{url}" do
      before do
        url = "https://designsystem.digital.gov/components/overview/"
        visit url
        matcher = Axe::Matchers::BeAxeClean.new
        @result = matcher.audit(page)
      end

      it "scanning #{url}" do
        # results = audit_result
        #   .failure_message
        #   .gsub!("Invocation: axe.run({:exclude=>[]}, {}, callback);", "")

        path = generate_filepath_from_url(url)
        puts "Preparing #{path}...."
        if @result.results.violations.any?
          puts "Writing #{path}...."
          File.open(path, "w") do |f|
            f << JSON.pretty_generate(@result.results.violations.collect(&:to_h))
          end
        end

        expect(page).to be_axe_clean
      end
    end
  end

end
