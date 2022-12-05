class IvnSourceComponentLink < ApplicationRecord
  belongs_to :ivn_source, primary_key: :from_id, foreign_key: :id
  belongs_to :ivn_component, primary_key: :to_id, foreign_key: :id
end
