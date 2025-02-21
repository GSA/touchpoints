class RemoveIvn < ActiveRecord::Migration[7.2]
  def change
    drop_table :ivn_component_links
    drop_table :ivn_components
    drop_table :ivn_source_component_links
    drop_table :ivn_sources
  end
end
