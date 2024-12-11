# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
	let(:organization) { FactoryBot.create(:organization) }
	let(:user) { FactoryBot.create(:user, organization:) }
	let(:form) { FactoryBot.create(:form, organization:) }

	context "radio_buttons question_type" do
		describe "submission validation" do
			let!(:question) { FactoryBot.create(:question, question_type: :radio_buttons, form: form, form_section: form.form_sections.first) }

			before do
				expect(form.questions.first.question_type).to eq("radio_buttons")
				@submission = Submission.create(form: question.form, answer_01: "a" )
			end

			it "ensure response corresponds to a question option" do
				expect(@submission.errors.messages).to include(question: ["answer_01 contains invalid values: a"])
			end
		end

		describe "submission validation" do
			let!(:question) { FactoryBot.create(:question, question_type: :radio_buttons, form: form, form_section: form.form_sections.first) }
			let!(:question_option_1) { FactoryBot.create(:question_option, question: question, position: 2, value: "B") }
			let!(:question_option_2) { FactoryBot.create(:question_option, question: question, position: 1, value: "A") }

			describe "valid response" do
				before do
					expect(form.questions.first.question_type).to eq("radio_buttons")
					@submission = Submission.create(form: question.form, answer_01: "A" )
				end

				it "is a valid response" do
					expect(@submission.valid?).to eq(true)
					expect(@submission.errors.empty?).to eq(true)
				end
			end

			describe "receives a question option that wasn't provided" do
				before do
					expect(form.questions.first.question_type).to eq("radio_buttons")
					@submission = Submission.create(form: question.form, answer_01: "Z,X" )
				end

				it "is invalid response" do
					expect(@submission.errors.messages).to include({question: ["answer_01 contains multiple valid values: Z, X"]})
				end
			end

			describe "receives at least 2 question option that wasn't provided OTHER" do
				let!(:other_question_option_3) { FactoryBot.create(:question_option, question: question, position: 3, other_option: true, value: "other") }

				before do
					expect(form.questions.first.question_type).to eq("radio_buttons")
					@submission = Submission.create(form: question.form, answer_01: "OTHER,Z,X" )
				end

				it "is invalid response" do
					expect(@submission.errors.messages).to include({question: ["answer_01 contains more than 1 'other' value: OTHER, Z, X"]})
				end
			end

			describe "receives at least 2 question option that wasn't provided OTHER" do
				let!(:other_question_option_3) { FactoryBot.create(:question_option, question: question, position: 3, other_option: true, value: "other") }

				before do
					expect(form.questions.first.question_type).to eq("radio_buttons")
				end

				it "is invalid response" do
					@submission = Submission.create(form: question.form, answer_01: "OTHER,Z,B" )
					expect(@submission.errors.messages).to include({question: ["answer_01 contains more than 1 'other' value: OTHER, Z"]})
				end

				it "is invalid response" do
					@submission = Submission.create(form: question.form, answer_01: "OTHER,Z,A,B" )
					expect(@submission.errors.messages).to include({question: ["answer_01 contains more than 1 'other' value: OTHER, Z"]})
				end
			end
		end
	end
end
