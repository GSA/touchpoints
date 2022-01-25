class OrganizationSerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :url,
    :abbreviation,
    :domain,
    :logo,
    :digital_analytics_path,
    :mission_statement,
    :mission_statement_url

end
