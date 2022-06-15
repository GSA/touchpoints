# frozen_string_literal: true

class AddFormLogo < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :logo, :string

    Form.all.each do |form|
      next if form.organization.logo.blank?

      form.update_attribute(:logo, form.organization.logo)
      Rails.logger.debug { "Updated Form ID: #{form.id} with #{form.organization.logo}" }
    end
  end
end
