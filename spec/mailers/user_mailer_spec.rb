require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "submission_notification" do
    let!(:organization) { FactoryBot.create(:organization) }
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:form) { FactoryBot.create(:form, organization: organization, user: user)}
    let!(:submission) { FactoryBot.create(:submission, form: form) }
    let(:mail) { UserMailer.submission_notification(submission_id: submission.id, emails: [user.email]) }

    it "renders the headers" do
      expect(mail.subject).to eq("New Submission to #{submission.form.name}")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([ENV.fetch("TOUCHPOINTS_EMAIL_SENDER")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Touchpoints.gov Response Notification")
      expect(mail.body.encoded).to match("New feedback has been submitted to your form, #{submission.form.name}.")
    end
  end

  describe "admin_summary" do
    let(:mail) { UserMailer.admin_summary }

    it "renders the headers" do
      expect(mail.subject).to eq("Admin summary")
      expect(mail.to).to eq(ENV.fetch("TOUCHPOINTS_ADMIN_EMAILS").split(","))
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
      expect(mail.to).to eq(ENV.fetch("TOUCHPOINTS_ADMIN_EMAILS").split(","))
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
      expect(mail.subject).to eq("New user account created")
      expect(mail.to).to eq([UserMailer.touchpoints_team])
      expect(mail.from).to eq([ENV.fetch("TOUCHPOINTS_EMAIL_SENDER")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("New user account created")
    end

  end

  describe "org_user_notification" do
    let(:user) { FactoryBot.create(:user) }
    let(:mail) { UserMailer.org_user_notification(user,user) }

    it "renders the headers" do
      expect(mail.subject).to eq("New user added to organization")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([ENV.fetch("TOUCHPOINTS_EMAIL_SENDER")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("New user added to organization")
    end

  end

  describe "no_org_notification" do
    let(:user) { FactoryBot.create(:user) }
    let(:mail) { UserMailer.no_org_notification(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("New user account creation failed")
      expect(mail.to).to eq([UserMailer.touchpoints_support])
      expect(mail.from).to eq([ENV.fetch("TOUCHPOINTS_EMAIL_SENDER")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("New user account creation failed")
    end

  end

end
