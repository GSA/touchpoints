# frozen_string_literal: true

class OrganizationSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :url,
             :abbreviation,
             :domain,
             :logo,
             :digital_analytics_path,
             :mission_statement,
             :mission_statement_url,
             :performance_url,
             :strategic_plan_url,
             :learning_agenda_url
end
