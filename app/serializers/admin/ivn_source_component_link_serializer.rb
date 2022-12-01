class Admin::IvnSourceComponentLinkSerializer < ActiveModel::Serializer
  attributes :id, :from_id, :to_id
end
