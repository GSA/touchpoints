# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :email,
             :first_name,
             :last_name,
             :position_title,
             :profile_photo
end
