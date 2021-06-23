class SetOmbCxReportingCollectionDefaults < ActiveRecord::Migration[6.1]
  def change
    change_column_default :omb_cx_reporting_collections, :volume_of_customers, 0
    change_column_default :omb_cx_reporting_collections, :volume_of_customers_provided_survey_opportunity, 0
    change_column_default :omb_cx_reporting_collections, :volume_of_respondents, 0
  end
end
