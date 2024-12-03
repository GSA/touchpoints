# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization:) }
  let(:form) { FactoryBot.create(:form, :open_ended_form, organization:) }
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

  context 'has question options' do
    let(:question_2) {
      Question.create!({
        form: form,
        form_section: form.form_sections.first,
        text: 'Question with options',
        question_type: 'radio_buttons',
        help_text: 'This is help text.',
        position: 2,
        answer_field: :answer_02
      })
    }

    before do
      QuestionOption.create!({
        question: question_2,
        text: 'A',
        value: 'A',
        position: 1,
      })

      QuestionOption.create!({
        question: question_2,
        text: 'B',
        value: 'B',
        position: 2,
      })

      QuestionOption.create!({
        question: question_2,
        text: 'C',
        value: 'C',
        position: 3,
      })
    end

    it 'has_other_question_option? is false' do
      expect(question_2.has_other_question_option?).to eq(false)
    end

    context 'with an "other" option' do
      before do
        QuestionOption.create!({
          question: question_2,
          text: 'D',
          value: 'D',
          position: 4,
          other_option: true
        })
      end

      it 'has_other_question_option? is true' do
        expect(question_2.has_other_question_option?).to eq(true)
      end
    end
  end
end
