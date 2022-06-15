# frozen_string_literal: true

namespace :one_offs do
  task migrate_website_managers: :environment do
    Website.all.each do |website|
      next if website.site_owner_email.blank?

      u = User.where(email: website.site_owner_email).first
      u.add_role(:website_manager, website) unless u&.has_role?(:website_manager, website)
    end
  end
end
