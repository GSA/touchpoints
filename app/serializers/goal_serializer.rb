# frozen_string_literal: true

class GoalSerializer < ActiveModel::Serializer
  attributes :id,
             :organization_id,
             :organization_name,
             :organization_abbreviation,
             :name,
             :description,
             :tags,
             :users,
             :four_year_goal,
             :position,
             :goal_statement,
             :challenge,
             :opportunity,
             :notes
end
