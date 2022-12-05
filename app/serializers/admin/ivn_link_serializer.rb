class Admin::IvnLinkSerializer < ActiveModel::Serializer
  attributes :id, :from_id, :to_id
end
