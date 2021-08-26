class GoalSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :name, :description, :tags, :users
end
