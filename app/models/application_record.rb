class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def set_uuid
  	self.uuid = SecureRandom.uuid  if !self.uuid.present?
  end
end
