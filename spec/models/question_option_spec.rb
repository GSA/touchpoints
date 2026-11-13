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

  describe 'interim uniqueness validation' do
    let!(:existing_option) do
      option_question.question_options.create!(text: 'Existing label', value: 'existing-value', position: 1)
    end
    let(:other_question) do
      FactoryBot.create(:question, form:, form_section: form.form_sections.first, answer_field: :answer_03)
    end

    [:text, :value].each do |attribute|
      it "rejects a new option with duplicate #{attribute} in the same question" do
        option = option_question.question_options.new(text: 'New label', value: 'new-value', position: 2)
        option[attribute] = existing_option[attribute]

        expect(option).not_to be_valid
        expect(option.errors[attribute]).to include('has already been taken')
      end

      it "rejects changing #{attribute} to an existing option's #{attribute}" do
        option = option_question.question_options.create!(text: 'New label', value: 'new-value', position: 2)

        expect(option.update(attribute => existing_option[attribute])).to be(false)
        expect(option.errors[attribute]).to include('has already been taken')
      end

    end

    it 'allows the same text and value in different questions' do
      option = other_question.question_options.new(
        text: existing_option.text, value: existing_option.value, position: 1,
      )

      expect(option.save).to be(true)
    end

    it 'checks value uniqueness after defaulting a blank value to the text' do
      option = option_question.question_options.new(text: existing_option.value, value: '', position: 2)

      expect(option).not_to be_valid
      expect(option.errors[:value]).to include('has already been taken')
    end

    context 'with legacy duplicate labels and values' do
      let!(:legacy_option) do
        option = option_question.question_options.create!(text: 'Legacy label', value: 'legacy-value', position: 2)
        # Simulate duplicate records that predate these validations.
        option.update_columns(text: existing_option.text, value: existing_option.value)
        option.reload
      end

      it 'allows saving unchanged duplicates and updating their positions' do
        expect(legacy_option.save).to be(true)
        expect(legacy_option.update(position: 3)).to be(true)
      end

      it 'allows correcting the label while leaving the duplicate value unchanged' do
        expect(legacy_option.update(text: 'Corrected label')).to be(true)
      end

      it 'allows correcting the value while leaving the duplicate label unchanged' do
        expect(legacy_option.update(value: 'corrected-value')).to be(true)
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
