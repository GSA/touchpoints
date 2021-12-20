class ObjectiveSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :organization_id, :goal_id, :milestone_id, :tags, :users
end
