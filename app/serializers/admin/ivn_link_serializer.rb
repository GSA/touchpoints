# frozen_string_literal: true

module Admin
  class IvnLinkSerializer < ActiveModel::Serializer
    attributes :id, :from_id, :to_id
  end
end
