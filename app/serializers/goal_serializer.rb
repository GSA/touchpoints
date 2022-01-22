class GoalSerializer < ActiveModel::Serializer
  attributes :id, :organization_id, :organization_name, :name, :description, :tags, :users
end
