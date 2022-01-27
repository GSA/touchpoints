class GoalSerializer < ActiveModel::Serializer
  attributes :id,
    :organization_id,
    :organization_name,
    :name,
    :description,
    :tags,
    :users,
    :four_year_goal,
    :position,
    :notes
    
end
