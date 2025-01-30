class AddFormsLegacyLinkFeatureFlag < ActiveRecord::Migration[7.2]
  def change
    add_column :forms, :legacy_link_feature_flag, :boolean, default: false

    Form.update_all(legacy_link_feature_flag: false)
  end
end
