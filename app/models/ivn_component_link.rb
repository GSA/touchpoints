class IvnComponentLink < ApplicationRecord
  belongs_to :ivn_component, primary_key: :id, foreign_key: :from_id
  belongs_to :to_ivn_component, primary_key: :id, foreign_key: :to_id
  # belongs_to :ivn_component
end
