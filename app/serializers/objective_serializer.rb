class ObjectiveSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :organization_id, :organization_name, :goal_id, :milestone_id, :tags, :users
end
