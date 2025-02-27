class RmFormLegacyLinkOption < ActiveRecord::Migration[8.0]
  def change
    remove_column :forms, :legacy_link_feature_flag
  end
end
