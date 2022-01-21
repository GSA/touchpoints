class PersonaSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :tags, :notes, :user_id
end
