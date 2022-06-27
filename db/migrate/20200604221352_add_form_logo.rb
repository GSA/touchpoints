class AddFormLogo < ActiveRecord::Migration[5.2]
  def change
    add_column :forms, :logo, :string

    Form.all.each do |form|
      next unless form.organization.logo.present?
      
      form.update_attribute(:logo, form.organization.logo)
      puts "Updated Form ID: #{form.id} with #{form.organization.logo}"
    end
  end
end
