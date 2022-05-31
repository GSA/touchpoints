class DigitalServiceAccountSerializer < ActiveModel::Serializer
  attributes :page, :size, :links

  def page
    @instance_options[:page]
  end

  def size
    @instance_options[:size]
  end

  def links
    @instance_options[:links]
  end


  attributes :id,
    :name,
    :organization_id,
    :organization_name,
    :organization_abbreviation,
    :user_id,
    :service,
    :service_url,
    :account,
    :language,
    :status,
    :short_description,
    :long_description,
    :tags
end
