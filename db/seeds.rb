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
require_relative 'seeds/forms/a11_v2'
require_relative 'seeds/forms/kitchen_sink'
require_relative 'seeds/forms/thumbs_up_down'
require_relative 'seeds/forms/yes_no'

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

org_2 = Organization.create!({
  name: "Farmers.gov",
  domain: "example.gov",
  url: "https://farmers.gov",
  abbreviation: "FARMERS"
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
  organization: example_gov,
  template: true,
  kind: "open ended",
  notes: "An open-ended Feedback Form useful for general website and program feedback.",
  user: admin_user,
  name: "Open-ended Feedback",
  title: "Custom Open-ended Title",
  instructions: "Share feedback about the new example.gov website and recommend additional features.",
  disclaimer_text: "Disclaimer Text Goes Here",
  delivery_method: "modal",
  modal_button_text: "Click here to leave feedback"

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
  organization: example_gov,
  template: true,
  kind: "recruiter",
  notes: "A form useful for recruiting users to participate in research.",
  user: admin_user,
  name: "Recruiter",
  title: "",
  instructions: "",
  disclaimer_text: "Disclaimer Text Goes Here",
  delivery_method: "modal",
  modal_button_text: "Click here to leave feedback"
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
  organization: example_gov,
  template: true,
  kind: "open ended with contact information",
  notes: "An open-ended feedback form with information to follow up with the user.",
  user: admin_user,
  name: "Open Ended Form with Contact Information",
  title: "",
  instructions: "",
  disclaimer_text: "Disclaimer Text Goes Here",
  delivery_method: "modal",
  modal_button_text: "Click here to leave feedback"
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
  answer_field: :answer_02,
  is_required: false,
})
Question.create!({
  form: open_ended_form_with_contact_information,
  form_section: open_ended_form_with_contact_information.form_sections.first,
  text: "Email",
  question_type: "text_field",
  position: 2,
  answer_field: :answer_03,
  is_required: false,
})

a11_form = Seeds::Forms.a11
a11_v2_form = Seeds::Forms.a11_v2
thumbs_up_down_form = Seeds::Forms.thumbs_up_down
kitchen_sink_form = Seeds::Forms.kitchen_sink
yes_no_form = Seeds::Forms.yes_no

UserRole.create(
  user: admin_user,
  form: a11_form,
  role: UserRole::Role::FormManager
)

UserRole.create(
  user: admin_user,
  form: a11_v2_form,
  role: UserRole::Role::FormManager
)

UserRole.create(
  user: admin_user,
  form: thumbs_up_down_form,
  role: UserRole::Role::FormManager
)

UserRole.create(
  user: admin_user,
  form: kitchen_sink_form,
  role: UserRole::Role::FormManager
)

UserRole.create(
  user: admin_user,
  form: recruiter_form,
  role: UserRole::Role::FormManager
)

UserRole.create(
  user: admin_user,
  form: open_ended_form_with_contact_information,
  role: UserRole::Role::FormManager
)

UserRole.create(
  user: admin_user,
  form: yes_no_form,
  role: UserRole::Role::FormManager
)


Submission.create!({
  form: open_ended_form,
  answer_01: "Body text"
})

Submission.create!({
  form: open_ended_form,
  answer_01: "Another body text " * 20
})

Submission.create!({
  form: recruiter_form,
  answer_01: "Mary",
  answer_02: "Public",
  answer_03: "public_user_3@example.com",
  answer_04: "5555550000"
})

100.times do |i|
  Submission.create!({
    form: open_ended_form,
    answer_01: "Body text"
  })
end

# TODO: Seed A11
range = [1,2,3,4,5]
50.times do |i|
  Submission.create!({
    form: a11_form,
    answer_01: range.sample,
    answer_02: range.sample,
    answer_03: range.sample,
    answer_04: range.sample,
    answer_05: range.sample,
    answer_06: range.sample,
    answer_07: range.sample
  })
  a11_form.update_attribute(:survey_form_activations, a11_form.survey_form_activations + 1)
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


## Services

service_1 = Service.create({
  name: "USPTO",
  organization: Organization.first
})
service_2 = Service.create({
  name: "IRS",
  organization: Organization.first
})
service_3 = Service.create({
  name: "HUD",
  organization: Organization.first
})
stage_before = ServiceStage.create({
  name: "Before",
  service: service_1
})
stage_during = ServiceStage.create({
  name: "During",
  service: service_1
})
stage_after = ServiceStage.create({
  name: "After",
  service: service_1
})
barrier_1 = Barrier.create({
  name: "technical"
})
barrier_2 = Barrier.create({
  name: "policy"
})
barrier_3 = Barrier.create({
  name: "location"
})
ServiceStageBarrier.create({
  service_stage: stage_before,
  barrier: barrier_1
})
ServiceStageBarrier.create({
  service_stage: stage_during,
  barrier: barrier_2
})
ServiceStageBarrier.create({
  service_stage: stage_after,
  barrier: barrier_3
})

Website.create!({
  domain: "gsa.gov",
  type_of_site: "Informational",
  production_status: "production"
})

Website.create!({
  domain: "digital.gov",
  type_of_site: "Informational",
  production_status: "production"
})

Website.create!({
  domain: "touchpoints.digital.gov",
  type_of_site: "Application",
  production_status: "production"
})

data_collection = Collection.create!({
  organization: Organization.first,
  service: service_1,
  user: User.all.sample,
  year: 2021,
  quarter: 2,
  name: "CX Quarterly Data Collection",
  start_date: "2021-01-01",
  end_date: "2021-03-31"
})

OmbCxReportingCollection.create!({
  collection: data_collection,
  service_provided: "Test CX Quarterly Reporting",
  q1_text: "Question 1",
  q1_1: rand(1000),
  q1_2: rand(1000),
  q1_3: rand(1000),
  q1_4: rand(1000),
  q1_5: rand(1000),
  q2_text: "Question 2",
  q2_1: rand(1000),
  q2_2: rand(1000),
  q2_3: rand(1000),
  q2_4: rand(1000),
  q2_5: rand(1000),
  q3_text: "Question 3",
  q3_1: rand(1000),
  q3_2: rand(1000),
  q3_3: rand(1000),
  q3_4: rand(1000),
  q3_5: rand(1000),
  q4_text: "Question 4",
  q4_1: rand(1000),
  q4_2: rand(1000),
  q4_3: rand(1000),
  q4_4: rand(1000),
  q4_5: rand(1000),
  q5_text: "Question 5",
  q5_1: rand(1000),
  q5_2: rand(1000),
  q5_3: rand(1000),
  q5_4: rand(1000),
  q5_5: rand(1000),
  q6_text: "Question 6",
  q6_1: rand(1000),
  q6_2: rand(1000),
  q6_3: rand(1000),
  q6_4: rand(1000),
  q6_5: rand(1000),
  q7_text: "Question 7",
  q7_1: rand(1000),
  q7_2: rand(1000),
  q7_3: rand(1000),
  q7_4: rand(1000),
  q7_5: rand(1000),
})
