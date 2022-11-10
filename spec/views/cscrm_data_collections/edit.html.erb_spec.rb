require 'rails_helper'

RSpec.describe "cscrm_data_collections/edit", type: :view do
  let(:cscrm_data_collection) {
    CscrmDataCollection.create!(
      leadership_roles: "MyString",
      stakeholder_champion_identified: "MyString",
      pmo_established: "MyString",
      interdisciplinary_team_established: "MyString",
      enterprise_risk_management_function_established: "MyString",
      enterprise_wide_scrm_policy_established: "MyString",
      agency_wide_scrm_strategy_and_implementation_plan_established: "MyString",
      funding_for_initial_operating_capability: "MyString",
      staffing: "MyString",
      roles_and_responsibilities: "MyString",
      missions_identified: "MyText",
      missions_identified_why_not: "MyText",
      prioritization_process: "MyText",
      considerations_in_procurement_processes: "MyString",
      conducts_scra_for_prioritized_products_and_services: "MyString",
      personnel_required_to_complete_training: "MyString",
      established_process_information_sharing_with_fasc: "MyString",
      cybersecurity_supply_chain_risk_considerations: "MyString"
    )
  }

  before(:each) do
    assign(:cscrm_data_collection, cscrm_data_collection)
  end

  it "renders the edit cscrm_data_collection form" do
    render

    assert_select "form[action=?][method=?]", admin_cscrm_data_collection_path(cscrm_data_collection), "post" do

      assert_select "input[name=?]", "cscrm_data_collection[leadership_roles]"

      assert_select "input[name=?]", "cscrm_data_collection[stakeholder_champion_identified]"

      assert_select "input[name=?]", "cscrm_data_collection[pmo_established]"

      assert_select "input[name=?]", "cscrm_data_collection[interdisciplinary_team_established]"

      assert_select "input[name=?]", "cscrm_data_collection[enterprise_risk_management_function_established]"

      assert_select "input[name=?]", "cscrm_data_collection[enterprise_wide_scrm_policy_established]"

      assert_select "input[name=?]", "cscrm_data_collection[agency_wide_scrm_strategy_and_implementation_plan_established]"

      assert_select "input[name=?]", "cscrm_data_collection[funding_for_initial_operating_capability]"

      assert_select "input[name=?]", "cscrm_data_collection[staffing]"

      assert_select "input[name=?]", "cscrm_data_collection[roles_and_responsibilities]"

      assert_select "textarea[name=?]", "cscrm_data_collection[missions_identified]"

      assert_select "textarea[name=?]", "cscrm_data_collection[missions_identified_why_not]"

      assert_select "textarea[name=?]", "cscrm_data_collection[prioritization_process]"

      assert_select "input[name=?]", "cscrm_data_collection[considerations_in_procurement_processes]"

      assert_select "input[name=?]", "cscrm_data_collection[conducts_scra_for_prioritized_products_and_services]"

      assert_select "input[name=?]", "cscrm_data_collection[personnel_required_to_complete_training]"

      assert_select "input[name=?]", "cscrm_data_collection[established_process_information_sharing_with_fasc]"

      assert_select "input[name=?]", "cscrm_data_collection[cybersecurity_supply_chain_risk_considerations]"
    end
  end
end
