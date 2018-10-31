class Container < ApplicationRecord
  before_create :create_container_in_gtm!

  has_many :touchpoints

  def embed_code_head
    GoogleApi.gtm_header_text(key: self.gtm_container_public_id)
  end

  def embed_code_body
    GoogleApi.gtm_body_text(key: self.gtm_container_public_id)
  end

  def gtm_container_url
    "https://tagmanager.google.com/#/admin/?accountId=#{ENV.fetch('GOOGLE_TAG_MANAGER_ACCOUNT_ID')}&containerId=#{gtm_container_id}"
  end


  private

    # Creates a GTM Container for this Touchpoint
    def create_container_in_gtm!
      return if Rails.env.test?

      @service = GoogleApi.new
      new_container = @service.create_account_container(name: "fba-#{Rails.env.downcase}-#{name.parameterize}")
      self.gtm_container_id = new_container.container_id
      self.gtm_container_public_id = new_container.public_id
    end
end
