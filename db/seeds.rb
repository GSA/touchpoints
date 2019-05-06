def production_suitable_seeds
  gsa = Organization.create!({
    name: "General Services Administration",
    abbreviation: "GSA",
    domain: "gsa.gov",
    url: "https://gsa.gov"
  })
  puts "Created Organization: #{gsa.name}"
end

production_suitable_seeds

# Seeds below are intended for
#   Staging and Development Environments; not Production.
return false if Rails.env.production?

puts "Cleaning Account Containers for Google Tag Manager Account #{ENV.fetch("GOOGLE_TAG_MANAGER_ACCOUNT_ID")}"
service = GoogleApi.new
service.clean_account_containers(account_id: ENV.fetch("GOOGLE_TAG_MANAGER_ACCOUNT_ID"))

example_gov = Organization.create!({
  name: "Example.gov",
  domain: "example.gov",
  url: "https://example.gov"
})
puts "Created Default Organization: #{example_gov.name}"

# Create Seeds
admin_user = User.new({
  organization: example_gov,
  email: "admin@example.gov",
  password: "password",
  admin: true
})
admin_user.skip_confirmation!
admin_user.save!
puts "Created Admin User: #{admin_user.email}"

digital_gov = Organization.create!({
  name: "Digital.gov",
  domain: "digital.gov",
  url: "https://digital.gov"
})
puts "Creating additional Organization: #{digital_gov.name}"

program_1 = Program.create!({
  name: "Program 1 for Digital.gov",
  organization: digital_gov,
  url: "https://digital.gov/program-name"
})
program_2 = Program.create!({
  name: "Program 2 for Digital.gov",
  organization: digital_gov,
  url: "https://digital.gov/program-name-2"
})

org_2 = Organization.create!({
  name: "Farmers.gov",
  domain: "example.gov",
  url: "https://farmers.gov"
})
program_3 = Program.create!({
  name: "Program 3 for Farmers.gov",
  organization: org_2,
  url: "https://farmers.gov/program-name-3"
})

org_3 = Organization.create!({
  name: "Cloud.gov",
  domain: "cloud.gov",
  url: "https://cloud.gov"
})

webmaster = User.new({
  email: "webmaster@example.gov",
  password: "password",
  organization: example_gov
})
webmaster.skip_confirmation!
webmaster.save!
puts "Created #{webmaster.email}"

organization_manager = User.new({
  email: "organization_manager@example.gov",
  password: "password",
  organization: example_gov,
  organization_manager: true
})
organization_manager.skip_confirmation!
organization_manager.save!
puts "Created #{organization_manager.email}"

service_manager = User.new({
  email: "service_manager@example.gov",
  password: "password",
  organization: example_gov
})
service_manager.skip_confirmation!
service_manager.save!
puts "Created #{service_manager.email}"

submission_viewer = User.new({
  email: "viewer@example.gov",
  password: "password",
  organization: example_gov
})
submission_viewer.skip_confirmation!
submission_viewer.save!
puts "Created #{submission_viewer.email}"

# Form Templates
form_1 = FormTemplate.create({
  name: "Open-ended",
  kind:  "open-ended",
  title: "Custom Open-ended Title",
  instructions: "Share feedback about the new example.gov website and recommend additional features.",
  disclaimer_text: "Disclaimer Text Goes Here",
  notes: ""
})

form_2 = FormTemplate.create({
  name: "Recruiter",
  kind:  "recruiter",
  title: "",
  instructions: "",
  disclaimer_text: "Disclaimer Text Goes Here",
  notes: ""
})

form_3 = FormTemplate.create({
  name: "À11 - 7 Question Form",
  kind:  "a11",
  title: "",
  instructions: "",
  disclaimer_text: "Disclaimer Text Goes Here",
  notes: ""
})

form_4 = FormTemplate.create({
  name: "Open Ended Form with Contact Information",
  kind:  "open-ended-with-contact-info",
  title: "",
  instructions: "",
  disclaimer_text: "Disclaimer Text Goes Here",
  notes: ""
})

# Forms
form_1 = Form.create({
  name: "Open-ended",
  kind:  "open-ended",
  title: "Custom Open-ended Title",
  instructions: "Share feedback about the new example.gov website and recommend additional features.",
  disclaimer_text: "Disclaimer Text Goes Here",
  notes: ""
})

form_2 = Form.create({
  name: "Recruiter",
  kind:  "recruiter",
  title: "",
  instructions: "",
  disclaimer_text: "Disclaimer Text Goes Here",
  notes: ""
})

form_3 = Form.create({
  name: "À11 - 7 Question Form",
  kind:  "a11",
  title: "",
  instructions: "",
  disclaimer_text: "Disclaimer Text Goes Here",
  notes: ""
})

form_4 = Form.create({
  name: "Open Ended Form with Contact Information",
  kind:  "open-ended-with-contact-info",
  title: "",
  instructions: "",
  disclaimer_text: "Disclaimer Text Goes Here",
  notes: ""
})

# A Service created by Admin
service_1  = Service.create!({
  organization: example_gov,
  name: "Test Service 1"
})
UserService.create(
  user: admin_user,
  service: service_1,
  role: UserService::Role::ServiceManager
)

# A 2nd Service created by Admin
service_2  = Service.create!({
  organization: example_gov,
  name: "Test Service 2"
})
UserService.create(
  user: admin_user,
  service: service_2,
  role: UserService::Role::ServiceManager
)

# A Service created by Webmaster
service_3  = Service.create!({
  organization: digital_gov,
  name: "Test Service 3"
})
UserService.create(
  user: webmaster,
  service: service_3,
  role: UserService::Role::ServiceManager
)
# Submission Viewer can view the Admin's Service
UserService.create(
  user: submission_viewer,
  service: service_2,
  role: UserService::Role::SubmissionViewer
)

# A Service created by Admin in another Organization
service_4  = Service.create!({
  organization: org_2,
  name: "Test Service 4 (for Farmers.gov)"
})
UserService.create(
  user: admin_user,
  service: service_4,
  role: UserService::Role::ServiceManager
)

# Manually create, then relate Containers to Services
container_1 = Container.create!({
  service: service_1,
  name: "#{digital_gov.name}'s Test Container 1"
})

container_2 = Container.create!({
  service: service_2,
  name: "#{digital_gov.name}'s Test Container 2"
})

container_3 = Container.create!({
  service: service_3,
  name: "#{org_2.name}'s Test Container 1"
})

container_4 = Container.create!({
  service: service_4,
  name: "#{org_2.name}'s Test Container 2"
})

# Touchpoints
touchpoint_1 = Touchpoint.create!({
  form: form_1,
  service: service_1,
  name: "Open-ended Feedback",
  purpose: "Soliciting feedback",
  meaningful_response_size: 30,
  behavior_change: "Looking for opportunities to improve",
  notification_emails: "ryan.wold@gsa.gov"
})

touchpoint_2 = Touchpoint.create!({
  form: form_2,
  service: service_1,
  name: "Recruiter",
  purpose: "Improving Customer Experience with proactive research and service",
  meaningful_response_size: 100,
  behavior_change: "We will use the this feedback to inform Product and Program decisions",
  notification_emails: "ryan.wold@gsa.gov"
})

touchpoint_3 = Touchpoint.create!({
  form: form_3,
  service: service_2,
  name: "A11 - 7 question test - DB",
  purpose: "CX",
  meaningful_response_size: 100,
  behavior_change: "Better customer service",
  notification_emails: "ryan.wold@gsa.gov"
})

Submission.create!({
  touchpoint: touchpoint_1,
  body: "Body text"
})

Submission.create!({
  touchpoint: touchpoint_1,
  body: "Another body text"
})

Submission.create!({
  touchpoint: touchpoint_2,
  first_name: "Mary",
  last_name: "Public",
  email: "public_user_3@example.com",
  phone_number: "5555550000"
})

# TODO: Seed A11
# Submission.create!({
#   touchpoint: touchpoint_3
# })


digital_gov_user = User.new({
  email: "user@digital.gov",
  password: "password"
})
digital_gov_user.skip_confirmation!
digital_gov_user.save!
puts "Created Test User in Secondary Organization: #{digital_gov_user.email}"
