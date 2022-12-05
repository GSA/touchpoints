def production_suitable_seeds
  @gsa = Organization.create!({
    name: 'General Services Administration',
    abbreviation: 'GSA',
    domain: 'gsa.gov',
    url: 'https://gsa.gov',
    digital_analytics_path: 'general-services-administration',
    mission_statement: 'Declaring the purpose of an organization and how it serves customers'
  })
  puts 'Created Organization: #{@gsa.name}'
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

if ENV['DEVELOPER_EMAIL_ADDRESS'].present?
  #assumes email addresses in the form user@domain
  domain = ENV['DEVELOPER_EMAIL_ADDRESS'].split('@')[1]
  developer_organization = Organization.create!({
    name: 'Development Org',
    domain: domain,
    url: 'https://lvh.me',
    abbreviation: 'DEV'
  })
  puts 'Created Default Organization: #{developer_organization.name}'

  developer_user = User.new({
    organization: developer_organization,
    email: ENV['DEVELOPER_EMAIL_ADDRESS'],
    password: 'password',
    admin: true,
    current_sign_in_at: Time.now,
  })
  developer_user.save!
  puts 'Created Developer User: #{developer_user.email}'
end

example_gov = Organization.create!({
  name: 'Example.gov',
  domain: 'example.gov',
  url: 'https://example.gov',
  abbreviation: 'EX'
})
puts 'Created Default Organization: #{example_gov.name}'

admin_user = User.new({
  organization: example_gov,
  email: 'ryan.wold+staging@gsa.gov',
  password: 'password',
  admin: true,
  registry_manager: true,
  current_sign_in_at: Time.now,
})
admin_user.save!
puts 'Created Admin User: #{admin_user.email}'

digital_gov = Organization.create!({
  name: 'Digital.gov',
  domain: 'digital.gov',
  url: 'https://digital.gov',
  abbreviation: 'DIGITAL'
})
puts 'Creating additional Organization: #{digital_gov.name}'

org_2 = Organization.create!({
  name: 'Farmers.gov',
  domain: 'example.gov',
  url: 'https://farmers.gov',
  abbreviation: 'FARMERS'
})

org_3 = Organization.create!({
  name: 'Cloud.gov',
  domain: 'cloud.gov',
  url: 'https://cloud.gov',
  abbreviation: 'CLOUD'
})

webmaster = User.new({
  email: 'webmaster@example.gov',
  password: 'password',
  organization: example_gov,
  current_sign_in_at: Time.now,
})
webmaster.save!
puts 'Created #{webmaster.email}'

touchpoint_manager = User.new({
  email: 'touchpoint_manager@example.gov',
  password: 'password',
  organization: example_gov,
  current_sign_in_at: Time.now,
})
touchpoint_manager.save!
puts 'Created #{touchpoint_manager.email}'

submission_viewer = User.new({
  email: 'viewer@example.gov',
  password: 'password',
  organization: example_gov,
  current_sign_in_at: Time.now - 100.days,
})
submission_viewer.save!
puts 'Created #{submission_viewer.email}'


#
# Service Providers
#

service_provider_1 = ServiceProvider.create({
  organization: example_gov,
  name: 'Example HISP',
  description: 'Description for an example HISP',
  notes: 'notes for example HISP',
  department: 'Example Department',
  department_abbreviation: 'dept',
  bureau: 'Example Bureau',
  slug: 'example-service1',
  new: false,
})

service_provider_2 = ServiceProvider.create({
  organization: example_gov,
  name: 'Example High Impact Service Provider - example.gov',
  description: 'A Description of the Example HISP',
  notes: 'notes on the example.gov HISP',
  department: 'Example',
  department_abbreviation: 'ex',
  bureau: 'CX Labs',
  slug: 'example-service2',
  new: false,
})

service_provider_3 = ServiceProvider.create({
  organization: Organization.first,
  name: 'GSA High Impact Service Provider - USA.gov',
  description: 'A Description of the USA.gov HISP',
  notes: 'notes on the usa.gov HISP',
  department: 'General Services Administration',
  department_abbreviation: 'gsa',
  bureau: 'Technology Transformation Services',
  slug: 'gsa-usagov',
  new: true,
})


#
# Services
#

service_1 = Service.create!({
  name: 'USPTO Trademarks',
  organization: Organization.first,
  hisp: true,
  notes: 'Headline notes about the service',
  description: 'A blurb describing this service. A few hundred words...',
  department: 'Department of Commerce',
  bureau: 'Patents and Trademarks',
  service_abbreviation: 'uspto',
  service_slug: 'doc-trademarks',
  url: 'https://uspto.gov/trademarks',
  service_owner_id: admin_user.id,
  service_provider: service_provider_1,
})
service_2 = Service.create!({
  organization: service_provider_2.organization,
  service_provider: service_provider_2,
  name: 'Example',
  service_owner_id: admin_user.id,
  hisp: true,
})
service_3 = Service.create!({
  organization: Organization.first,
  service_provider: service_provider_2,
  service_owner_id: webmaster.id,
  name: 'HUD',
  hisp: true,
})
service_4 = Service.create!({
  organization: Organization.first,
  service_provider: service_provider_3,
  service_owner_id: webmaster.id,
  name: 'IRS',
  hisp: true,
  })
service_5 = Service.create!({
  organization: Organization.first,
  service_provider: service_provider_1,
  service_owner_id: admin_user.id,
  name: 'Touchpoints',
  hisp: false,
})

form_that_belongs_to_a_service = Form.create!({
  organization: example_gov,
  template: true,
  kind: 'open ended',
  notes: "An open-ended Feedback Form related to #{service_5.name}",
  user: admin_user,
  name: 'Open-ended Feedback',
  title: "An open-ended Feedback Form related to #{service_5.name}",
  instructions: 'Share',
  disclaimer_text: '',
  delivery_method: 'modal',
  modal_button_text: 'Click here to leave feedback',
  service: service_5,
})

stage_before = ServiceStage.create({
  name: 'Before',
  service: service_1
})
stage_during = ServiceStage.create({
  name: 'During',
  service: service_1
})
stage_after = ServiceStage.create({
  name: 'After',
  service: service_1
})

barrier_1 = Barrier.create({
  name: 'technical'
})
barrier_2 = Barrier.create({
  name: 'policy'
})
barrier_3 = Barrier.create({
  name: 'location'
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


#
# Forms
#

## Create the Open-ended Form
open_ended_form = Form.create!({
  organization: example_gov,
  template: true,
  kind: 'open ended',
  notes: 'An open-ended Feedback Form useful for general website and program feedback.',
  user: admin_user,
  name: 'Open-ended Feedback',
  title: 'Custom Open-ended Title',
  instructions: 'Share feedback about the new example.gov website and recommend additional features.',
  disclaimer_text: 'Disclaimer Text Goes Here',
  delivery_method: 'modal',
  modal_button_text: 'Click here to leave feedback',
})
Question.create!({
  form: open_ended_form,
  form_section: open_ended_form.form_sections.first,
  text: 'How can we improve this website to better meet your needs?',
  question_type: 'textarea',
  position: 1,
  answer_field: :answer_01,
  is_required: true,
})

## Create the Recruiter Form
recruiter_form = Form.create({
  organization: example_gov,
  template: true,
  kind: 'recruiter',
  notes: 'A form useful for recruiting users to participate in research.',
  user: admin_user,
  name: 'Recruiter',
  title: '',
  instructions: '',
  disclaimer_text: 'Disclaimer Text Goes Here',
  delivery_method: 'modal',
  modal_button_text: 'Click here to leave feedback'
})
Question.create!({
  form: recruiter_form,
  form_section: recruiter_form.form_sections.first,
  text: 'Name',
  question_type: 'text_field',
  position: 1,
  answer_field: :answer_01,
  is_required: false,
})
Question.create!({
  form: recruiter_form,
  form_section: recruiter_form.form_sections.first,
  text: 'Email',
  question_type: 'text_field',
  position: 2,
  answer_field: :answer_02,
  is_required: false,
})
Question.create!({
  form: recruiter_form,
  form_section: recruiter_form.form_sections.first,
  text: 'Phone Number',
  question_type: 'text_field',
  position: 3,
  answer_field: :answer_03,
  is_required: false,
})

open_ended_form_with_contact_information = Form.create!({
  organization: example_gov,
  template: true,
  kind: 'open ended with contact information',
  notes: 'An open-ended feedback form with information to follow up with the user.',
  user: admin_user,
  name: 'Open Ended Form with Contact Information',
  title: '',
  instructions: '',
  disclaimer_text: 'Disclaimer Text Goes Here',
  delivery_method: 'modal',
  modal_button_text: 'Click here to leave feedback',
  service: service_1,
})
Question.create!({
  form: open_ended_form_with_contact_information,
  form_section: open_ended_form_with_contact_information.form_sections.first,
  text: 'How can we improve this website to better meet your needs?',
  question_type: 'textarea',
  position: 1,
  answer_field: :answer_01,
  is_required: true,
})
Question.create!({
  form: open_ended_form_with_contact_information,
  form_section: open_ended_form_with_contact_information.form_sections.first,
  text: 'Name',
  question_type: 'text_field',
  position: 2,
  answer_field: :answer_02,
  is_required: false,
})
Question.create!({
  form: open_ended_form_with_contact_information,
  form_section: open_ended_form_with_contact_information.form_sections.first,
  text: 'Email',
  question_type: 'text_field',
  position: 3,
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
  answer_01: 'Body text'
})

Submission.create!({
  form: open_ended_form,
  answer_01: 'Another body text ' * 20
})

Submission.create!({
  form: recruiter_form,
  answer_01: 'Mary',
  answer_02: 'Public',
  answer_03: 'public_user_3@example.com',
  answer_04: '5555550000'
})

100.times do |i|
  Submission.create!({
    form: open_ended_form,
    answer_01: 'Body text'
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
  email: 'user@digital.gov',
  password: 'password',
  current_sign_in_at: Time.now,
})
digital_gov_user.save!
puts 'Created Test User in Secondary Organization: #{digital_gov_user.email}'

## Generate admin
admin_emails = ENV.fetch('TOUCHPOINTS_ADMIN_EMAILS').split(',')
admin_emails.each do |email|
  User.new({
    email: email.strip,
    password: SecureRandom.hex,
    admin: true
  }).save!
end


#
# Websites
#

Website.create!({
  organization: @gsa,
  domain: 'gsa.gov',
  type_of_site: 'Informational',
  production_status: 'production'
})

Website.create!({
  organization: @gsa,
  domain: 'digital.gov',
  type_of_site: 'Informational',
  production_status: 'production'
})

Website.create!({
  organization: @gsa,
  domain: 'touchpoints.digital.gov',
  type_of_site: 'Application',
  production_status: 'production'
})

Website.create!({
  organization: @gsa,
  domain: 'subdomain.digital.gov',
  type_of_site: 'Application',
  production_status: 'production'
})
Website.create!({
  organization: @gsa,
  domain: 'subdomain.gsa.gov',
  type_of_site: 'Application',
  production_status: 'production'
})

data_collection = Collection.create!({
  organization: Organization.first,
  service_provider: service_provider_1,
  user: User.all.sample,
  year: 2021,
  quarter: 2,
  name: 'CX Quarterly Data Collection',
  start_date: '2021-01-01',
  end_date: '2021-03-31',
  rating: 'TRUE',
})

data_collection = Collection.create!({
  organization: Organization.first,
  service_provider: service_provider_1,
  user: User.all.sample,
  year: 2021,
  quarter: 3,
  name: 'CX Quarterly Data Collection',
  start_date: '2021-04-01',
  end_date: '2021-06-30',
  rating: 'FALSE',
})

data_collection = Collection.create!({
  organization: example_gov,
  service_provider: service_provider_2,
  user: User.all.sample,
  year: 2021,
  quarter: 1,
  name: 'CX Quarterly Data Collection',
  start_date: '2020-10-31',
  end_date: '2020-12-31',
  rating: 'PARTIAL',
})

data_collection = Collection.create!({
  organization: example_gov,
  service_provider: service_provider_2,
  user: User.all.sample,
  year: 2021,
  quarter: 2,
  name: 'CX Quarterly Data Collection',
  start_date: '2021-01-01',
  end_date: '2021-03-31',
  rating: 'PARTIAL',
})

data_collection = Collection.create!({
  organization: example_gov,
  service_provider: service_provider_2,
  user: User.all.sample,
  year: 2021,
  quarter: 3,
  name: 'CX Quarterly Data Collection',
  start_date: '2021-04-01',
  end_date: '2021-06-30',
  rating: 'PARTIAL',
})

data_collection = Collection.create!({
  organization: example_gov,
  service_provider: service_provider_2,
  user: User.all.sample,
  year: 2021,
  quarter: 4,
  name: 'CX Quarterly Data Collection',
  start_date: '2021-07-01',
  end_date: '2021-09-30',
  rating: 'PARTIAL',
})


OmbCxReportingCollection.create!({
  collection: data_collection,
  service: service_1,
  service_provided: 'Test CX Quarterly Reporting',
  q1_text: 'Question 1',
  q1_1: rand(1000),
  q1_2: rand(1000),
  q1_3: rand(1000),
  q1_4: rand(1000),
  q1_5: rand(1000),
  q2_text: 'Question 2',
  q2_1: rand(1000),
  q2_2: rand(1000),
  q2_3: rand(1000),
  q2_4: rand(1000),
  q2_5: rand(1000),
  q3_text: 'Question 3',
  q3_1: rand(1000),
  q3_2: rand(1000),
  q3_3: rand(1000),
  q3_4: rand(1000),
  q3_5: rand(1000),
  q4_text: 'Question 4',
  q4_1: rand(1000),
  q4_2: rand(1000),
  q4_3: rand(1000),
  q4_4: rand(1000),
  q4_5: rand(1000),
  q5_text: 'Question 5',
  q5_1: rand(1000),
  q5_2: rand(1000),
  q5_3: rand(1000),
  q5_4: rand(1000),
  q5_5: rand(1000),
  q6_text: 'Question 6',
  q6_1: rand(1000),
  q6_2: rand(1000),
  q6_3: rand(1000),
  q6_4: rand(1000),
  q6_5: rand(1000),
  q7_text: 'Question 7',
  q7_1: rand(1000),
  q7_2: rand(1000),
  q7_3: rand(1000),
  q7_4: rand(1000),
  q7_5: rand(1000),
})


#
# Goals
#
# four_year_goal: true = Strategic Goal
# four_year_goal: false = APG = Annual Performance Goal
#

@strategic_goal_1 = Goal.create!({
  organization: @gsa,
  name: "Real Estate Solutions: Financially and environmentally sustainable, accessible, and responsive workspace solutions that enable a productive Federal workforce",
  four_year_goal: true
})

@apg_goal_1 = Goal.create!({
  organization: @gsa,
  name: "Right-Size GSA's Real Estate Portfolio",
  four_year_goal: false,
  tag_list: ["Pandemic response", "General government & management"]
})

@apg_goal_2 = Goal.create!({
  organization: @gsa,
  name: "Increase Adoption of GSA-Sponsored Identity Solutions",
  four_year_goal: false,
  tag_list: ["Shared Services"],

  goal_statement: "GSA will increase adoption of Login.gov, a simple, secure, and equitable shared service at the forefront of the public’s digital identity..."
})

Persona.create!({
  name: 'Public User',
})
Persona.create!({
  name: 'Federal Staff User'
})
Persona.create!({
  name: 'Example Persona 3'
})

@organizations = Organization.all

for i in (1..20) do
IvnSource.create!({
  name: "IVN Source Name #{i}",
  description: "IVN Source Description #{i}",
  url: "https://example.gov/ivn-source-url-#{i}",
  organization: @organizations.sample,
})
end

for i in (1..50) do
IvnComponent.create!({
  name: "IVN Description Name #{i}",
  description: "IVN Description Description #{i}",
  url: "https://example.gov/ivn-component-url-#{i}",
})
end

@ivn_components = IvnComponent.all
@ivn_sources = IvnSource.all

for i in (1..100) do
  from_id = @ivn_components.sample
  to_id = (@ivn_components - [from_id]).sample

  IvnComponentLink.create!({
    from_id: from_id.id,
    to_id: to_id.id,
  })
end

for i in (1..50) do
  from_id = @ivn_sources.sample
  to_id = @ivn_components.sample

  IvnSourceComponentLink.create!({
    from_id: from_id.id,
    to_id: to_id.id,
  })
end

puts 'Created User Personas: #{admin_user.email}'
