class IvnComponent < ApplicationRecord
  has_many :ivn_component_links, foreign_key: :to_id
  has_many :ivn_components, through: :ivn_component_links
end


