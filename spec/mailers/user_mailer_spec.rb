require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "submission_notification" do
    let(:mail) { UserMailer.submission_notification }

    it "renders the headers" do
      expect(mail.subject).to eq("Submission notification")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "admin_summary" do
    let(:mail) { UserMailer.admin_summary }

    it "renders the headers" do
      expect(mail.subject).to eq("Admin summary")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
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
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
