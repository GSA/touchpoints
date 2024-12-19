# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
	let(:organization) { FactoryBot.create(:organization) }
	let(:user) { FactoryBot.create(:user, organization:) }
	let(:form) { FactoryBot.create(:form, organization:) }

	context "textarea question_type" do
		describe "character limit" do
			let!(:question) { FactoryBot.create(:question, question_type: :textarea, form: form, form_section: form.form_sections.first, character_limit: 10) }

			before do
				expect(form.questions.first.question_type).to eq("textarea")
				@submission = Submission.create(form: question.form, answer_01: "more than twelve characters" )
			end

			it "enforces character limit" do
				expect(@submission.errors.messages).to include(answer_01: ["exceeds character limit of 10"])
			end
		end
	end
end
