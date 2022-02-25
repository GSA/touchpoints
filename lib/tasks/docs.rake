namespace :docs do

  task :draw_state_diagrams do
    sh "bundle exec rake aasm-diagram:generate[Service]"
    sh "bundle exec rake aasm-diagram:generate[Collection]"
    sh "bundle exec rake aasm-diagram:generate[Website,production_status]"
    sh "bundle exec rake aasm-diagram:generate[Form]"
    sh "bundle exec rake aasm-diagram:generate[Submission]"

    puts "Check the /tmp directory for State diagrams as .pngs"
  end
end
