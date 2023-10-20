# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'components/forms/_custom_layout.html.erb' do
  let(:form) { create(:form) }

  subject(:rendered) do
    render partial: 'components/forms/custom_layout', locals: { form: }
  end

  context 'with required fields' do
    let(:form) { create(:form, :a11) }

    it 'displays required field label' do
      expect(rendered).to have_content(strip_tags(t('form.required_field_html')))
    end
  end

  context 'without required fields' do
    let(:form) { create(:form, :star_ratings) }

    it 'does not display required field label' do
      expect(rendered).not_to have_content(strip_tags(t('form.required_field_html')))
    end
  end
end
