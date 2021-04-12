class Website < ApplicationRecord
  validates :domain, presence: true
end
