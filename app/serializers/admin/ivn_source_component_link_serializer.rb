# frozen_string_literal: true

module Admin
  class IvnSourceComponentLinkSerializer < ActiveModel::Serializer
    attributes :id, :from_id, :to_id
  end
end
