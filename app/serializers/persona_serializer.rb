# frozen_string_literal: true

class PersonaSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :tag_list, :notes, :user_id
end
