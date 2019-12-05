require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "submission_notification" do
    let(:user) { FactoryBot.create(:user) }
    let!(:service) { FactoryBot.create(:service) }
    let!(:touchpoint) { FactoryBot.create(:touchpoint, :with_form, service: service) }
    let!(:submission) { FactoryBot.create(:submission, touchpoint: touchpoint) }
    let(:mail) { UserMailer.submission_notification(submission: submission, emails: [user.email]) }

    it "renders the headers" do
      expect(mail.subject).to eq("New Submission to #{submission.touchpoint.name}")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([ENV.fetch("TOUCHPOINTS_EMAIL_SENDER")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Touchpoints.gov Submission Notification")
      expect(mail.body.encoded).to match("New feedback has been submitted to your form, #{submission.touchpoint.name}.")
    end
  end

  describe "admin_summary" do
    let(:mail) { UserMailer.admin_summary }

    it "renders the headers" do
      expect(mail.subject).to eq("Admin summary")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq([ENV.fetch("TOUCHPOINTS_EMAIL_SENDER")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "webmaster_summary" do
    let(:mail) { UserMailer.webmaster_summary }

    it "renders the headers" do
      expect(mail.subject).to eq("Webmaster summary")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq([ENV.fetch("TOUCHPOINTS_EMAIL_SENDER")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "new_user_notification" do
    let(:user) { FactoryBot.create(:user) }
    let(:mail) { UserMailer.new_user_notification(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("New user account registration #{user.email}")
      expect(mail.to).to eq([ENV.fetch("TOUCHPOINTS_TEAM")])
      expect(mail.from).to eq([ENV.fetch("TOUCHPOINTS_EMAIL_SENDER")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("New User Account Notification")
    end

  end

  describe "org_user_notification" do
    let(:user) { FactoryBot.create(:user) }
    let(:mail) { UserMailer.org_user_notification(user,user) }

    it "renders the headers" do
      expect(mail.subject).to eq("A new user has been added to your organization")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([ENV.fetch("TOUCHPOINTS_EMAIL_SENDER")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("New User Added to Org")
    end

  end

  describe "no_org_notification" do
    let(:user) { FactoryBot.create(:user) }
    let(:mail) { UserMailer.no_org_notification(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Problem with new user account registration, #{user.email} -- organization not found")
      expect(mail.to).to eq([ENV.fetch("TOUCHPOINTS_SUPPORT")])
      expect(mail.from).to eq([ENV.fetch("TOUCHPOINTS_EMAIL_SENDER")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("New User Account Creation Failed, No Organization Found")
    end

  end

end
