# frozen_string_literal: true

class GoalSerializer < ActiveModel::Serializer
  attributes :id,
             :organization_id,
             :organization_name,
             :organization_abbreviation,
             :name,
             :description,
             :tags,
             :four_year_goal,
             :position,
             :goal_statement,
             :challenge,
             :opportunity,
             :notes,
             :sponsoring_users

  def sponsoring_users
    ActiveModel::Serializer::CollectionSerializer.new(object.sponsoring_users, serializer: UserSerializer)
  end
end
