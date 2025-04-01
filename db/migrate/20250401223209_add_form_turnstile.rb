class AddFormTurnstile < ActiveRecord::Migration[8.0]
  def change
    add_column :forms, :enable_turnstile, :boolean, default: false, comment: "Set to true to enable Cloudfront Turnstile"
  end
end
