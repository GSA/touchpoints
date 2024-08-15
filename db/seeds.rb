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

organizational_admin_user = User.new({
  organization: example_gov,
  email: 'organizational_admin@gsa.gov',
  password: 'password',
  organizational_admin: true,
  current_sign_in_at: Time.now,
})
organizational_admin_user.save!
puts 'Created Organizational Admin User: #{organizational_admin_user.email}'

digital_gov = Organization.create!({
  name: 'Digital.gov',
  domain: 'digital.gov',
  url: 'https://digital.gov',
  abbreviation: 'DIGITAL',
  parent_id: @gsa.id
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
  slug: 'example-service1',
  inactive: false,
  new: false,
})

service_provider_2 = ServiceProvider.create({
  organization: example_gov,
  name: 'Example High Impact Service Provider - example.gov',
  description: 'A Description of the Example HISP',
  notes: 'notes on the example.gov HISP',
  slug: 'example-service2',
  inactive: false,
  new: false,
})

service_provider_3 = ServiceProvider.create({
  organization: Organization.first,
  name: 'GSA High Impact Service Provider - USA.gov',
  description: 'A Description of the USA.gov HISP',
  notes: 'notes on the usa.gov HISP',
  slug: 'gsa-usagov',
  new: true,
})

service_provider_4 = ServiceProvider.create({
  organization: Organization.first,
  name: 'An example of an inactive HISP',
  description: 'A Description of an old HISP',
  notes: 'notes on and old HISP',
  slug: 'example-legacy',
  inactive: true,
  new: false,
})

service_provider_5 = ServiceProvider.create({
  organization: digital_gov,
  name: 'Digital gov HISP',
  description: 'A HISP in an Org that has a parent',
  notes: 'A HISP in an Org that has a parent',
  slug: 'digital-gov',
  inactive: false,
  new: true,
})

service_provider_6 = ServiceProvider.create({
  organization: org_2,
  name: 'Farmers Service Provider',
  description: 'Farmers Service Provider description',
  notes: 'Farmers Service Provider notes',
  slug: 'farmers',
  inactive: false,
  new: true,
})


#
# Services
#

service_1 = Service.create!({
  name: 'USPTO Trademarks',
  organization: Organization.first,
  hisp: true,
  year_designated: 2023,
  notes: 'Headline notes about the service',
  description: 'A blurb describing this service. A few hundred words...',
  short_description: 'A short description of this service.',
  department: 'Department of Commerce',
  bureau: 'Patents and Trademarks',
  service_slug: 'doc-trademarks',
  url: 'https://uspto.gov/trademarks',
  service_owner_id: admin_user.id,
  service_provider: service_provider_1,
})
service_2 = Service.create!({
  organization: service_provider_2.organization,
  service_provider: service_provider_2,
  year_designated: 2022,
  short_description: 'A short description of this service.',
  name: 'Example',
  service_owner_id: admin_user.id,
  hisp: true,
})
service_3 = Service.create!({
  organization: Organization.first,
  service_provider: service_provider_2,
  year_designated: 2021,
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
service_5 = Service.create!({
  organization: org_2,
  service_provider: service_provider_6,
  service_owner_id: touchpoint_manager.id,
  name: 'Farmers',
  hisp: true,
})

# NOTE:
# this form can be used for testing the form feedback email
# that is sent when a user archives a form that has been used, with conditions
form_that_belongs_to_a_service = Form.create!({
  organization: example_gov,
  template: false,
  kind: 'open ended',
  notes: "An open-ended Feedback Form related to #{service_5.name}",
  name: 'Open-ended Feedback',
  title: "An open-ended Feedback Form related to #{service_5.name}",
  instructions: 'Share',
  disclaimer_text: '',
  delivery_method: 'modal',
  modal_button_text: 'Click here to leave feedback',
  service: service_5,
})

# Set the form's `created_at` date far enough in the past to trigger a feedback email
form_that_belongs_to_a_service.update_attribute(:created_at, Time.now - 4.weeks)

Question.create!({
  form: form_that_belongs_to_a_service,
  form_section: form_that_belongs_to_a_service.form_sections.first,
  text: 'How can we improve?',
  question_type: 'textarea',
  position: 1,
  answer_field: :answer_01,
  is_required: true,
})

# more than 1,000, to test async sidekiq form export jobs
1010.times.each do |i|
 Submission.create!({
    form: form_that_belongs_to_a_service,
    answer_01: "aaaaa",
  })
end


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
a11_v2_form_template = Seeds::Forms.a11_v2

a11_v2_form = Seeds::Forms.a11_v2
a11_v2_form.update_attribute(:template, false)

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

100.times do |i|
  options = [1, 2, 3, 4]
  random_options = options.sample(rand(4))

  if rand(2) == 1
    Submission.create!({
      form: a11_v2_form,
      answer_01: 1,
      answer_02: random_options.join(','),
      answer_04: 'Positive free text'
    })
  else
    Submission.create!({
      form: a11_v2_form,
      answer_01: 0,
      answer_03: random_options.join(','),
      answer_04: ' Negative free text'
    })
  end
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

puts 'Creating User Personas...'

Persona.create!({
  name: 'Public User',
})
Persona.create!({
  name: 'Federal Staff User'
})
Persona.create!({
  name: 'Example Persona 3'
})


puts 'Creating IVN Sources, Components, and Links...'
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

puts 'Creating CSCRM Data Collections...'
def random_words
  list = %w(Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua Ut enim ad minim veniam quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur Excepteur sint occaecat cupidatat non proident sunt in culpa qui officia deserunt mollit anim id est laborum)

  list.sample(15).join(" ")
end

for i in (1..40) do
  org = @organizations.all.sample
  user = org.users.sample || User.all.sample

  CscrmDataCollection.create!({
    user: user,
    organization: user.organization,
    bureau_id: "",
    year: [2022, 2023, 2024].sample,
    quarter: [1, 2, 3, 4].sample,
    agency_roles: CscrmDataCollection.agency_roles_options.sample,
    agency_roles_comments: random_words,
    leadership_roles: CscrmDataCollection.leadership_roles_options.sample,
    stakeholder_champion_identified: CscrmDataCollection.stakeholder_champion_identified_options.sample,
    stakeholder_champion_identified_comments: random_words,
    interdisciplinary_team_established: CscrmDataCollection.interdisciplinary_team_established_options.sample,
    interdisciplinary_team_established_comments: random_words,
    pmo_established: CscrmDataCollection.pmo_established_options.sample,
    pmo_established_comments: random_words,
    enterprise_wide_scrm_policy_established: CscrmDataCollection.enterprise_wide_scrm_policy_established_options.sample,
    enterprise_wide_scrm_policy_established_comments: random_words,
    funding_for_initial_operating_capability: CscrmDataCollection.funding_for_initial_operating_capability_options.sample,
    funding_for_initial_operating_capability_comments: random_words,
    staffing: CscrmDataCollection.staffing_options.sample,
    staffing_comments: random_words,
    agency_wide_scrm_strategy_and_implementation_plan_established: CscrmDataCollection.agency_wide_scrm_strategy_and_implementation_plan_options.sample,
    agency_wide_scrm_strategy_and_implementation_plan_comments: random_words,
    enterprise_risk_management_function_established: CscrmDataCollection.enterprise_risk_management_function_established_options.sample,
    enterprise_risk_management_function_established_comments: random_words,
    roles_and_responsibilities: CscrmDataCollection.roles_and_responsibilities_options.sample,
    roles_and_responsibilities_comments: random_words,
    missions_identified: CscrmDataCollection.missions_identified_options,
    missions_identified_comments: random_words,
    prioritization_process: CscrmDataCollection.prioritization_process_options.sample,
    prioritization_process_comments: random_words,
    considerations_in_procurement_processes: CscrmDataCollection.considerations_in_procurement_processes_options.sample,
    considerations_in_procurement_processes_comments: random_words,
    conducts_scra_for_prioritized_products_and_services: CscrmDataCollection.conducts_scra_for_prioritized_products_and_services_options.sample,
    conducts_scra_for_prioritized_products_and_services_comments: random_words,
    personnel_required_to_complete_training: CscrmDataCollection.personnel_required_to_complete_training_options.sample,
    established_process_information_sharing_with_fasc: CscrmDataCollection.established_process_information_sharing_options.sample,
    established_process_information_sharing_with_fasc_comments: random_words,
    cybersecurity_supply_chain_risk_considerations: CscrmDataCollection.cybersecurity_supply_chain_risk_considerations_options.sample,
    general_comments: random_words
  })

  CscrmDataCollection2.create!({
    user: user,
    organization: user.organization,
    bureau_id: "",
    year: [2023, 2023, 2025].sample,
    quarter: [1, 2, 3, 4].sample,
    interdisciplinary_team: CscrmDataCollection2.question_1[:options].to_a.sample[1],
    interdisciplinary_team_comments: random_words,
    pmo_established: CscrmDataCollection2.question_2[:options].to_a.sample[1],
    pmo_established_comments: random_words,
    established_policy: CscrmDataCollection2.question_3[:options].to_a.sample[1],
    established_policy_comments: random_words,
    supply_chain_acquisition_procedures: CscrmDataCollection2.question_4[:options].to_a.sample[1],
    supply_chain_acquisition_procedures_comments: random_words,
    funding: CscrmDataCollection2.question_5[:options].to_a.sample[1],
    funding_comments: random_words,
    identified_staff: CscrmDataCollection2.question_6[:options].to_a.sample[1],
    identified_staff_comments: random_words,
    strategy_plan: CscrmDataCollection2.question_7[:options].to_a.sample[1],
    strategy_plan_comments: random_words,
    governance_structure: CscrmDataCollection2.question_8[:options].to_a.sample[1],
    governance_structure_comments: random_words,
    clearly_defined_roles: CscrmDataCollection2.question_9[:options].to_a.sample[1],
    clearly_defined_roles_comments: random_words,
    identified_assets_and_essential_functions: CscrmDataCollection2.question_10[:options].to_a.sample[1],
    identified_assets_and_essential_functions_comments: random_words,
    prioritization_process: CscrmDataCollection2.question_11[:options].to_a.sample[1],
    prioritization_process_comments: random_words,
    considerations_in_procurement_processes: CscrmDataCollection2.question_12[:options].to_a.sample[1],
    considerations_in_procurement_processes_comments: random_words,
    documented_methodology: CscrmDataCollection2.question_13[:options].to_a.sample[1],
    documented_methodology_comments: random_words,
    conducts_scra_for_prioritized_products_and_services: CscrmDataCollection2.question_14[:options].to_a.sample[1],
    conducts_scra_for_prioritized_products_and_services_comments: random_words,
    personnel_required_to_complete_training: CscrmDataCollection2.question_15[:options].to_a.sample[1],
    personnel_required_to_complete_training_comments: random_words,
    established_process_information_sharing_with_fasc: CscrmDataCollection2.question_16[:options].to_a.sample[1],
    established_process_information_sharing_with_fasc_comments: random_words,
    cybersecurity_supply_chain_risk_considerations: CscrmDataCollection2.question_17[:options].to_a.sample[1],
    cybersecurity_supply_chain_risk_considerations_comments: random_words,
    process_for_product_authenticity: CscrmDataCollection2.question_18[:options].to_a.sample[1],
    process_for_product_authenticity_comments: random_words,
    cscrm_controls_incorporated_into_ssp: CscrmDataCollection2.question_19[:options].to_a.sample[1],
    cscrm_controls_incorporated_into_ssp_comments: random_words,
    comments: random_words,
  })
end

for i in (1..20) do
  DigitalServiceAccount.create!({
    organization_list: [@gsa.id],
    name: "Social Media Account #{i}",
    account: DigitalServiceAccount.list.sample,
    aasm_state: DigitalServiceAccount.aasm.states.map(&:name).sample,
    service_url: "https://example.lvh.me/account#{i}"
  })

  DigitalProduct.create({
    organization_list: [@gsa.id],
    name: "Digital Product #{i}",
    aasm_state: DigitalProduct.aasm.states.map(&:name).sample
  })
end

CxCollection.create!({
  name: "CX Quarterly Reporting",
  organization_id: @gsa.id,
  service_provider_id: service_provider_1.id,
  service_id: service_provider_1.services.first.id,
  fiscal_year: 2024,
  quarter: 1,
  user: touchpoint_manager
})

CxCollection.create!({
  name: "CX Quarterly Reporting",
  organization_id: @gsa.id,
  service_provider_id: service_provider_1.id,
  service_id: service_provider_1.services.first.id,
  fiscal_year: 2024,
  quarter: 2,
  user: touchpoint_manager
})

CxCollection.create!({
  name: "CX Quarterly Reporting",
  organization_id: @gsa.id,
  service_provider_id: service_provider_1.id,
  service_id: service_provider_1.services.first.id,
  fiscal_year: 2024,
  quarter: 3,
  user: touchpoint_manager
})
CxCollection.create!({
  name: "CX Quarterly Reporting",
  organization_id: @gsa.id,
  service_provider_id: service_provider_1.id,
  service_id: service_provider_1.services.first.id,
  fiscal_year: 2024,
  quarter: 4,
  user: touchpoint_manager
})

CxCollection.create!({
  name: "CX Quarterly Reporting",
  organization_id: digital_gov.id,
  service_provider_id: service_provider_1.id,
  service_id: service_provider_1.services.first.id,
  fiscal_year: 2024,
  quarter: 4,
  user: touchpoint_manager
})

CxCollection.create!({
  name: "CX Quarterly Reporting",
  organization_id: org_2.id,
  service_provider_id: service_provider_1.id,
  service_id: service_provider_1.services.first.id,
  fiscal_year: 2024,
  quarter: 4,
  user: touchpoint_manager
})
