# frozen_string_literal: true

class IvnSourceSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :url
end
