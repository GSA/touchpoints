require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "submission_notification" do
    let(:user) { FactoryBot.create(:user) }
    let(:submission) { FactoryBot.create(:submission) }
    let(:mail) { UserMailer.submission_notification(submission: submission, emails: [user.email]) }

    it "renders the headers" do
      expect(mail.subject).to eq("New Submission to #{submission.touchpoint.name}")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["from@example.gov"])
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
      expect(mail.from).to eq(["from@example.gov"])
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
      expect(mail.from).to eq(["from@example.gov"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
