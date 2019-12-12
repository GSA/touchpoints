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

require_relative 'seeds/forms/a11'
require_relative 'seeds/forms/kitchen_sink'

# Create Seeds

if ENV["DEVELOPER_EMAIL_ADDRESS"].present?
  #assumes email addresses in the form user@domain
  domain = ENV["DEVELOPER_EMAIL_ADDRESS"].split("@")[1]
  developer_organization = Organization.create!({
    name: "Development Org",
    domain: domain,
    url: "https://lvh.me",
    abbreviation: "DEV"
  })
  puts "Created Default Organization: #{developer_organization.name}"

  developer_user = User.new({
    organization: developer_organization,
    email: ENV["DEVELOPER_EMAIL_ADDRESS"],
    password: "password",
    admin: true
  })
  developer_user.save!
  puts "Created Developer User: #{developer_user.email}"
end

example_gov = Organization.create!({
  name: "Example.gov",
  domain: "example.gov",
  url: "https://example.gov",
  abbreviation: "EX"
})
puts "Created Default Organization: #{example_gov.name}"

admin_user = User.new({
  organization: example_gov,
  email: "ryan.wold+staging@gsa.gov",
  password: "password",
  admin: true
})
admin_user.save!
puts "Created Admin User: #{admin_user.email}"

digital_gov = Organization.create!({
  name: "Digital.gov",
  domain: "digital.gov",
  url: "https://digital.gov",
  abbreviation: "DIGITAL"
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
  url: "https://farmers.gov",
  abbreviation: "FARMERS"
})
program_3 = Program.create!({
  name: "Program 3 for Farmers.gov",
  organization: org_2,
  url: "https://farmers.gov/program-name-3"
})

org_3 = Organization.create!({
  name: "Cloud.gov",
  domain: "cloud.gov",
  url: "https://cloud.gov",
  abbreviation: "CLOUD"
})

webmaster = User.new({
  email: "webmaster@example.gov",
  password: "password",
  organization: example_gov
})
webmaster.save!
puts "Created #{webmaster.email}"

organization_manager = User.new({
  email: "organization_manager@example.gov",
  password: "password",
  organization: example_gov,
  organization_manager: true
})
organization_manager.save!
puts "Created #{organization_manager.email}"

touchpoint_manager = User.new({
  email: "touchpoint_manager@example.gov",
  password: "password",
  organization: example_gov
})
touchpoint_manager.save!
puts "Created #{touchpoint_manager.email}"

submission_viewer = User.new({
  email: "viewer@example.gov",
  password: "password",
  organization: example_gov
})
submission_viewer.save!
puts "Created #{submission_viewer.email}"

# Forms

## Create the Open-ended Form
open_ended_form = Form.create!({
  template: true,
  kind: "open ended",
  user: admin_user,
  name: "Open-ended",
  title: "Custom Open-ended Title",
  instructions: "Share feedback about the new example.gov website and recommend additional features.",
  disclaimer_text: "Disclaimer Text Goes Here",
  notes: "",
  character_limit: 6000
})
Question.create!({
  form: open_ended_form,
  form_section: open_ended_form.form_sections.first,
  text: "How can we improve this website to better meet your needs?",
  question_type: "textarea",
  position: 1,
  answer_field: :answer_01,
  is_required: true,
})

## Create the Recruiter Form
recruiter_form = Form.create({
  template: true,
  kind: "recruiter",
  user: admin_user,
  name: "Recruiter",
  title: "",
  instructions: "",
  disclaimer_text: "Disclaimer Text Goes Here",
  notes: ""
})
Question.create!({
  form: recruiter_form,
  form_section: recruiter_form.form_sections.first,
  text: "Name",
  question_type: "text_field",
  position: 1,
  answer_field: :answer_01,
  is_required: false,
})
Question.create!({
  form: recruiter_form,
  form_section: recruiter_form.form_sections.first,
  text: "Email",
  question_type: "text_field",
  position: 2,
  answer_field: :answer_02,
  is_required: false,
})
Question.create!({
  form: recruiter_form,
  form_section: recruiter_form.form_sections.first,
  text: "Phone Number",
  question_type: "text_field",
  position: 3,
  answer_field: :answer_03,
  is_required: false,
})

open_ended_form_with_contact_information = Form.create({
  template: true,
  kind: "open ended with contact information",
  user: admin_user,
  name: "Open Ended Form with Contact Information",
  title: "",
  instructions: "",
  disclaimer_text: "Disclaimer Text Goes Here",
  notes: "",
  character_limit: 6000
})
Question.create!({
  form: open_ended_form_with_contact_information,
  form_section: open_ended_form_with_contact_information.form_sections.first,
  text: "How can we improve this website to better meet your needs?",
  question_type: "textarea",
  position: 1,
  answer_field: :answer_01,
  is_required: true,
})
Question.create!({
  form: open_ended_form_with_contact_information,
  form_section: open_ended_form_with_contact_information.form_sections.first,
  text: "Name",
  question_type: "text_field",
  position: 1,
  answer_field: :answer_01,
  is_required: false,
})
Question.create!({
  form: open_ended_form_with_contact_information,
  form_section: open_ended_form_with_contact_information.form_sections.first,
  text: "Email",
  question_type: "text_field",
  position: 2,
  answer_field: :answer_02,
  is_required: false,
})

a11_form = Seeds::Forms.a11
kitchen_sink_form = Seeds::Forms.kitchen_sink

# Touchpoints
touchpoint_1 = Touchpoint.create!({
  organization: example_gov,
  form: open_ended_form,
  name: "Open-ended Feedback",
  purpose: "Soliciting feedback",
  meaningful_response_size: 30,
  behavior_change: "Looking for opportunities to improve",
  notification_emails: "ryan.wold@gsa.gov"
})
UserRole.create(
  user: admin_user,
  touchpoint: touchpoint_1,
  role: UserRole::Role::TouchpointManager
)

touchpoint_2 = Touchpoint.create!({
  organization: example_gov,
  form: recruiter_form,
  name: "Recruiter",
  purpose: "Improving Customer Experience with proactive research and service",
  meaningful_response_size: 100,
  behavior_change: "We will use the this feedback to inform Product and Program decisions",
  notification_emails: "ryan.wold@gsa.gov"
})
UserRole.create(
  user: admin_user,
  touchpoint: touchpoint_2,
  role: UserRole::Role::TouchpointManager
)

touchpoint_3 = Touchpoint.create!({
  organization: example_gov,
  form: a11_form,
  name: "A11 - 7 question test",
  purpose: "CX",
  meaningful_response_size: 100,
  behavior_change: "Better customer service"
})
UserRole.create(
  user: admin_user,
  touchpoint: touchpoint_3,
  role: UserRole::Role::TouchpointManager
)

touchpoint_4 = Touchpoint.create!({
  organization: example_gov,
  form: open_ended_form_with_contact_information,
  name: "A11 - 7 question test - DB",
  purpose: "CX",
  meaningful_response_size: 100,
  behavior_change: "Better customer service",
  notification_emails: "ryan.wold@gsa.gov"
})
UserRole.create(
  user: admin_user,
  touchpoint: touchpoint_4,
  role: UserRole::Role::TouchpointManager
)

Submission.create!({
  touchpoint: touchpoint_1,
  answer_01: "Body text"
})

Submission.create!({
  touchpoint: touchpoint_1,
  answer_01: "Another body text " * 20
})

Submission.create!({
  touchpoint: touchpoint_2,
  answer_01: "Mary",
  answer_02: "Public",
  answer_03: "public_user_3@example.com",
  answer_04: "5555550000"
})

# TODO: Seed A11
range = [1,2,3,4,5]
50.times do |i|
  Submission.create!({
    touchpoint: touchpoint_3,
    answer_01: range.sample,
    answer_02: range.sample,
    answer_03: range.sample,
    answer_04: range.sample,
    answer_05: range.sample,
    answer_06: range.sample,
    answer_07: range.sample
  })
  touchpoint_3.update_attribute(:survey_form_activations, touchpoint_3.survey_form_activations + 1)
end

digital_gov_user = User.new({
  email: "user@digital.gov",
  password: "password"
})
digital_gov_user.save!
puts "Created Test User in Secondary Organization: #{digital_gov_user.email}"

## Generate admin
admin_emails = ENV.fetch("TOUCHPOINTS_ADMIN_EMAILS").split(",")
admin_emails.each do |email|
  User.new({
    email: email.strip,
    password: SecureRandom.hex,
    admin: true
  }).save!
end
