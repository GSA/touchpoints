# frozen_string_literal: true

class ObjectiveSerializer < ActiveModel::Serializer
  attributes :id,
             :name, :description,
             :organization_id,
             :organization_name,
             :goal_id,
             :milestone_id,
             :position,
             :tags,
             :users
end
