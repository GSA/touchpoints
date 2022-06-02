namespace :docs do

  task :generate do
    Rake::Task["docs:draw_erd"].invoke
    Rake::Task["docs:draw_state_diagrams"].invoke
  end

  task :draw_erd do
    sh "bundle exec erd"

    puts "Check erd.pdf for an Entity Relationship Diagram of /app/models/"
    puts "puts uses .erdconfig for configuration settings"
  end

  task :draw_state_diagrams do
    sh "bundle exec rake aasm-diagram:generate[Service]"
    sh "bundle exec rake aasm-diagram:generate[Collection]"
    sh "bundle exec rake aasm-diagram:generate[Website,production_status]"
    sh "bundle exec rake aasm-diagram:generate[Form]"
    sh "bundle exec rake aasm-diagram:generate[Submission]"
    sh "bundle exec rake aasm-diagram:generate[DigitalProduct]"
    sh "bundle exec rake aasm-diagram:generate[DigitalServiceAccount]"

    puts "Check the /tmp directory for State diagrams as .pngs"
  end
end
