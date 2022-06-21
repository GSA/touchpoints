# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionOption, type: :model do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization:) }
  let(:form) { FactoryBot.create(:form, :open_ended_form, organization:, user:) }
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
    before do
      @question_option = QuestionOption.create(text: 'Option 1', question: option_question, position: 1)
    end

    it 'assign the value as text by default' do
      expect(@question_option.value).to eq(@question_option.text)
    end
  end
end
