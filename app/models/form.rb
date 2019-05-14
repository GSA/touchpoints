class Form < ApplicationRecord
  has_one :touchpoint

  validates :name, presence: true
end
