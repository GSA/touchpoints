# frozen_string_literal: true

namespace :cf do
  desc 'Only run on the first application instance'
  task on_first_instance: :environment do
    instance_index = begin
      JSON.parse(ENV.fetch('VCAP_APPLICATION', nil))['instance_index']
    rescue StandardError
      nil
    end
    exit(0) unless instance_index.zero?
  end

  task log_new_relic_deployment: :environment do
    sh 'bundle exec newrelic deployment'
  end
end
