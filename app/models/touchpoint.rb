class Touchpoint < ApplicationRecord

  belongs_to :organization
  before_save :create_container_in_gtm

  validates :name, presence: true

  def gtm_container_url
    "https://tagmanager.google.com/#/admin/?accountId=#{ENV.fetch('GOOGLE_TAG_MANAGER_ACCOUNT_ID')}&containerId=#{gtm_container_id}"
  end

  def embed_code
    GoogleApi.gtm_header_text(key: "asdf")
  end

  def embed_code_body
    GoogleApi.gtm_body_text(key: "asdf")
  end

  def create_container_in_gtm
    @service = GoogleApi.new
    new_container = @service.create_account_container(name: "fba-#{Rails.env.downcase}-#{name.parameterize}")
    self.gtm_container_id = new_container.container_id
  end
end
