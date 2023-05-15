class UserApiKeys < ActiveRecord::Migration[7.0]
  def change
    User.where("api_key IS NOT NULL").each do |user|
      @existing_key = user.api_key
      user.update(api_key: "")
      user.update(api_key: @existing_key)
    end
  end
end
