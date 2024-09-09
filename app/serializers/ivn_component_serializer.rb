# frozen_string_literal: true

class IvnComponentSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :url
end
