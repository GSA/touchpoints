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

webmaster = User.new({
  email: "webmaster@example.com",
  password: "password"
})
webmaster.skip_confirmation!
webmaster.save!


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


Touchpoint.create({
  organization_id: org_1.id,
  name: "Mandatory 7 question test",
  purpose: "Working toward our CAP Goals and fulfilling the requirements of the 7 question test",
  meaningful_response_size: 100,
  behavior_change: "We will use the feedback to inform our Citizen Experience CAP Plan next year",
  notification_emails: "ryan.wold@gsa.gov"
})

Touchpoint.create({
  organization_id: org_1.id,
  name: "Open-ended Feedback",
  purpose: "Soliciting feedback",
  meaningful_response_size: 30,
  behavior_change: "Looking for opportunities to improve",
  notification_emails: "ryan.wold@gsa.gov"
})

Touchpoint.create({
  organization_id: org_2.id,
  name: "A11 - 7 question test",
  purpose: "Compliance",
  meaningful_response_size: 300,
  behavior_change: "End of year reporting",
  notification_emails: "ryan.wold@gsa.gov"
})
