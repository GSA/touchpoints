class AddMetricsToOmbCxReportingCollections < ActiveRecord::Migration[6.1]
  def change
    add_column :omb_cx_reporting_collections, :operational_metrics, :text
  end
end
