# frozen_string_literal: true

class GoalTargetSerializer < ActiveModel::Serializer
  attributes :id, :goal, :target_date_at, :assertion, :kpi, :starting_value, :target_value, :current_value
end
