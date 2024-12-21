# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionOption, type: :model do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization:) }
  let(:form) { FactoryBot.create(:form, :open_ended_form, organization:) }
  let!(:option_question) { FactoryBot.create(:question, form:, question_type: 'checkbox', form_section: form.form_sections.first, answer_field: :answer_02) }

  context 'without question or position' do
    before do
      @question_option = QuestionOption.create(text: 'Option 1')
    end

    it 'requires a question' do
      expect(@question_option.errors.messages[:question]).to eq(['must exist'])
    end

    it 'requires a position order' do
      expect(@question_option.errors.messages[:position]).to eq(["can't be blank"])
    end
  end

  context 'with question' do
    context 'no value set' do
      before do
        @question_option = QuestionOption.create(text: 'Option 1', question: option_question, position: 1)
      end

      it 'assign the value as text by default' do
        expect(@question_option.value).to eq(@question_option.text)
      end
    end

    context 'with value set' do
      before do
        @question_option = QuestionOption.create(text: 'Option 1', question: option_question, position: 1, value: "123")
      end

      it 'assign the value as text by default' do
        expect(@question_option.value).to eq("123")
      end
    end
  end

  context 'with a question that has an other Question Option already' do
    before do
      question_option = QuestionOption.create(text: 'Other Option 1', question: option_question, position: 1, value: "123", other_option: true)
      @question_option2 = QuestionOption.create(text: 'Another Other Option', question: option_question, position: 2, value: "456", other_option: true)
    end

    it 'does not save and has an error message' do
      expect(@question_option2.errors.messages).to eq({ question_option: ["only one 'other_option' can be true for a question"] })
    end
  end
end
