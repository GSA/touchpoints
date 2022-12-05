class IvnSource < ApplicationRecord
  belongs_to :organization
  has_many :ivn_links
  has_many :ivn_components, through: :ivn_links
end
