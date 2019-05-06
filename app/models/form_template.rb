class FormTemplate < ApplicationRecord
  validates :name, presence: true
  validates :kind, presence: true
end
