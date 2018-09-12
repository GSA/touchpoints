# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

admin_user = User.create({
  email: "admin@example.com",
  password: "password"
})
admin_user.confirm

Touchpoint.create({
  organization_id: nil,
  name: "Mandatory 7 question test",
  purpose: "Working toward our CAP Goals and fulfilling the requirements of the 7 question test",
  meaningful_response_size: 100,
  behavior_change: "We will use the feedback to inform our Citizen Experience CAP Plan next year",
  notification_emails: "ryan.wold@gsa.gov",
  embed_code: nil
})
