# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

# Cleanup GTM
service = GoogleApi.new
service.clean_account_containers(account_id: ENV.fetch("GOOGLE_TAG_MANAGER_ACCOUNT_ID"))

# Create Seeds
admin_user = User.new({
  email: "admin@example.com",
  password: "password",
  admin: true
})
admin_user.skip_confirmation!
admin_user.save!


org_1 = Organization.create({
  name: "Digital.gov",
  url: "https://digital.gov"
})
org_2 = Organization.create({
  name: "Farmers.gov",
  url: "https://farmers.gov"
})
org_3 = Organization.create({
  name: "Cloud.gov",
  url: "https://cloud.gov"
})

webmaster = User.new({
  email: "webmaster@example.com",
  password: "password",
  organization: org_1
})
webmaster.skip_confirmation!
webmaster.save!

# Forms
form_1 = Form.create({
  name: "Open-ended",
  kind:  "open-ended",
  notes: ""
})

form_2 = Form.create({
  name: "Recruiter",
  kind:  "recruiter",
  notes: ""
})

form_3 = Form.create({
  name: "À11 - 7 Question Form",
  kind:  "a11",
  notes: ""
})

# Touchpoints
touchpoint_1 = Touchpoint.create({
  organization_id: org_1.id,
  form_id: form_1.id,
  name: "Open-ended Feedback",
  purpose: "Soliciting feedback",
  meaningful_response_size: 30,
  behavior_change: "Looking for opportunities to improve",
  notification_emails: "ryan.wold@gsa.gov",
  enable_google_sheets: false
  })

touchpoint_2 = Touchpoint.create({
  organization_id: org_1.id,
  form_id: form_2.id,
  name: "Recruiter",
  purpose: "Improving Customer Experience with proactive research and service",
  meaningful_response_size: 100,
  behavior_change: "We will use the this feedback to inform Product and Program decisions",
  notification_emails: "ryan.wold@gsa.gov",
  enable_google_sheets: false
})


touchpoint_3 = Touchpoint.create({
  organization_id: org_2.id,
  form_id: form_3.id,
  name: "A11 - 7 question test",
  purpose: "Compliance",
  meaningful_response_size: 300,
  behavior_change: "End of year reporting",
  notification_emails: "ryan.wold@gsa.gov",
  enable_google_sheets: true
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
