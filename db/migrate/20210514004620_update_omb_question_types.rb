class UpdateOmbQuestionTypes < ActiveRecord::Migration[6.1]
  def change
    (1..11).each do |i|
      OmbCxReportingCollection.where("q#{i}_1 = ''").update_all("q#{i}_1": 0)
      OmbCxReportingCollection.where("q#{i}_2 = ''").update_all("q#{i}_2": 0)
      OmbCxReportingCollection.where("q#{i}_3 = ''").update_all("q#{i}_3": 0)
      OmbCxReportingCollection.where("q#{i}_4 = ''").update_all("q#{i}_4": 0)
      OmbCxReportingCollection.where("q#{i}_5 = ''").update_all("q#{i}_5": 0)
      change_column :omb_cx_reporting_collections, "q#{i}_1", :integer, using: "CAST(q#{i}_1 AS integer)", default: 0
      change_column :omb_cx_reporting_collections, "q#{i}_2", :integer, using: "CAST(q#{i}_2 AS integer)", default: 0
      change_column :omb_cx_reporting_collections, "q#{i}_3", :integer, using: "CAST(q#{i}_3 AS integer)", default: 0
      change_column :omb_cx_reporting_collections, "q#{i}_4", :integer, using: "CAST(q#{i}_4 AS integer)", default: 0
      change_column :omb_cx_reporting_collections, "q#{i}_5", :integer, using: "CAST(q#{i}_5 AS integer)", default: 0
    end
  end
end
