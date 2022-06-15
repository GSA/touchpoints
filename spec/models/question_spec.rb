# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization:) }
  let(:form) { FactoryBot.create(:form, :open_ended_form, organization:, user:) }
  let!(:question) { form.questions.first }
  let!(:new_question) { Question.create(form:, answer_field: 'answer_01') }

  context '' do
    before do
      expect(question.answer_field).to eq('answer_01')
    end

    it 'not a valid record' do
      expect(new_question.valid?).to be false
    end

    it 'requires a form section' do
      expect(new_question.errors.collect(&:attribute)).to include(:form_section)
    end

    it 'requires a question type' do
      expect(new_question.errors.collect(&:attribute)).to include(:question_type)
    end

    it 'enforces uniqueness for answer_field' do
      expect(new_question.errors.collect(&:attribute)).to include(:answer_field)
    end
  end
end
