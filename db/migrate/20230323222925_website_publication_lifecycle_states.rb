class WebsitePublicationLifecycleStates < ActiveRecord::Migration[7.0]
  def change
    
    Website.all.each do |website|
      case website.production_status
      when "in_development"
        website.update(aasm_state: :created)
      when "request_approved"
        website.update(aasm_state: :created)
        website.update(production_status: :in_development)
      when "newly_requested"
        website.update(aasm_state: :created)
        website.update(production_status: :in_development)
      when "staging"
        website.update(aasm_state: :created)
      when "production"
        website.update(aasm_state: :published)
      when "redirect"
        website.update(aasm_state: :published)
      when "archived"
        website.update(aasm_state: :archived)
      when "decommissioned"
        website.update(aasm_state: :archived)
      end
    end

  end
end
