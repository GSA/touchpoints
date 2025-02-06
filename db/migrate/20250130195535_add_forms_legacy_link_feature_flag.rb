class AddFormsLegacyLinkFeatureFlag < ActiveRecord::Migration[7.2]
  def change
    add_column :forms, :legacy_link_feature_flag, :boolean, default: false, comment: "when true, render fba-button as an A, otherwise render as BUTTON"

    Form.update_all(legacy_link_feature_flag: false)
  end
end
