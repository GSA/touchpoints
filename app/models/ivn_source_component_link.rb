# frozen_string_literal: true

class IvnSourceComponentLink < ApplicationRecord
  belongs_to :ivn_source, foreign_key: :from_id
  belongs_to :ivn_component, foreign_key: :to_id
end
