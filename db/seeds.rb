def production_suitable_seeds
  @gsa = Organization.create!({
    name: 'General Services Administration',
    abbreviation: 'GSA',
    domain: 'gsa.gov',
    url: 'https://gsa.gov',
    digital_analytics_path: 'general-services-administration',
    mission_statement: 'Declaring the purpose of an organization and how it serves customers'
  })
  puts "Created Organization: #{@gsa.name}"
end

production_suitable_seeds

# Seeds below are intended for
#   Staging and Development Environments; not Production.
return false if Rails.env.production?

require_relative 'seeds/forms/a11'
require_relative 'seeds/forms/a11_v2'
require_relative 'seeds/forms/kitchen_sink'
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
  puts "Created Default Organization: #{developer_organization.name}"

  developer_user = User.new({
    organization: developer_organization,
    email: ENV['DEVELOPER_EMAIL_ADDRESS'],
    password: 'password',
    admin: true,
    current_sign_in_at: Time.now,
  })
  developer_user.save!
  puts "Created Developer User: #{developer_user.email}"
end

example_gov = Organization.create!({
  name: 'Example.gov',
  domain: 'example.gov',
  url: 'https://example.gov',
  abbreviation: 'EX'
})
puts "Created Default Organization: #{example_gov.name}"

admin_user = User.new({
  organization: example_gov,
  email: 'ryan.wold+staging@gsa.gov',
  password: 'password',
  admin: true,
  registry_manager: true,
  current_sign_in_at: Time.now,
})
admin_user.save!
puts "Created Admin User: #{admin_user.email}"

organizational_admin_user = User.new({
  organization: example_gov,
  email: 'organizational_admin@gsa.gov',
  password: 'password',
  organizational_admin: true,
  current_sign_in_at: Time.now,
})
organizational_admin_user.save!
puts "Created Organizational Admin User: #{organizational_admin_user.email}"

digital_gov = Organization.create!({
  name: 'Digital.gov',
  domain: 'digital.gov',
  url: 'https://digital.gov',
  abbreviation: 'DIGITAL',
  parent_id: @gsa.id
})
puts "Creating additional Organization: #{digital_gov.name}"

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
puts "Created #{webmaster.email}"

touchpoint_manager = User.new({
  email: 'touchpoint_manager@example.gov',
  password: 'password',
  organization: example_gov,
  current_sign_in_at: Time.now,
})
touchpoint_manager.save!
puts "Created #{touchpoint_manager.email}"

submission_viewer = User.new({
  email: 'viewer@example.gov',
  password: 'password',
  organization: example_gov,
  current_sign_in_at: Time.now - 100.days,
})
submission_viewer.save!
puts "Created #{submission_viewer.email}"


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
  kind: 'open_ended',
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
    answer_01: Faker::Lorem.paragraph,
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
  kind: 'open_ended',
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
  kind: 'open_ended',
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
  answer_02: 'public_user_3@example.com',
  answer_03: '5555550000'
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
      answer_04: 'Negative free text'
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
puts "Created Test User in Secondary Organization: #{digital_gov_user.email}"

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

data_collection = CxCollection.create!({
  organization: service_1.organization,
  service_provider: service_provider_1,
  service: service_1,
  name: 'CX Quarterly Data Collection',
  user: User.all.sample,
  fiscal_year: 2021,
  quarter: 2,
  rating: 'TRUE',
  number_of_interactions: 123_456,
  number_of_people_offered_the_survey: 9_876,
  likert_or_thumb_question: "thumbs_up_down",
  trust_question_text: "How are you?",
  survey_title: "",
  channel: "",
  service_stage_id: "",
  transaction_point: "",
  digital_service_or_contact_center: "",
  service_type: "",

})

CxCollection.create!({
  organization: service_provider_3.organization,
  service_provider: service_provider_3,
  service: service_4,
  user: User.all.sample,
  fiscal_year: 2021,
  quarter: 3,
  name: 'CX Quarterly Data Collection',
  rating: 'FALSE',
})

CxCollection.create!({
  organization: service_provider_3.organization,
  service_provider: service_provider_3,
  service: service_4,
  user: User.all.sample,
  fiscal_year: 2021,
  quarter: 1,
  name: 'CX Quarterly Data Collection',
  rating: 'PARTIAL',
})

CxCollection.create!({
  organization: service_provider_3.organization,
  service_provider: service_provider_3,
  service: service_4,
  user: User.all.sample,
  fiscal_year: 2021,
  quarter: 2,
  name: 'CX Quarterly Data Collection',
  rating: 'PARTIAL',
})

CxCollection.create!({
  organization: service_provider_3.organization,
  service_provider: service_provider_3,
  service: service_4,
  user: User.all.sample,
  fiscal_year: 2021,
  quarter: 3,
  name: 'CX Quarterly Data Collection',
  rating: 'PARTIAL',
})

CxCollection.create!({
  organization: service_provider_3.organization,
  service_provider: service_provider_3,
  service: service_4,
  user: User.all.sample,
  fiscal_year: 2021,
  quarter: 4,
  name: 'CX Quarterly Data Collection',
  rating: 'PARTIAL',
})


CxCollectionDetail.create!({
  cx_collection: data_collection,
  transaction_point: "along the way",
  channel: Service.channels.sample ,
  service_stage_id: data_collection.service.service_stages.first,
  volume_of_customers: 123_456,
  volume_of_customers_provided_survey_opportunity: 54_321,
  volume_of_respondents: 6_789,
  omb_control_number: "1234-5678",
  reflection_text: "things are going",
  federal_register_url: "",
  survey_type: "",
  survey_title: "A-11 customer feedback",
  trust_question_text: "Did this service increase your trust?"
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

for i in (1..20) do
  DigitalServiceAccount.create!({
    organization_list: [@gsa.id],
    name: "Social Media Account #{i}",
    service: DigitalServiceAccount.list.sample,
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

cx_collection = CxCollection.create({
  organization: Organization.first,
  service: Service.first,
  service_provider: ServiceProvider.first,
  user: User.first,
  fiscal_year: 2024,
  quarter: 1,
  name: "CX Collection"
})
cx_collection_detail = CxCollectionDetail.create(
  cx_collection: cx_collection,
  service: Service.first,
  channel: "website",
  transaction_point: "end"
)
cx_collection_detail_upload = CxCollectionDetailUpload.new
1000.times.each do |i|
  n = CxResponse.create({
    cx_collection_detail: cx_collection_detail,
    cx_collection_detail_upload: cx_collection_detail_upload
  })
end