
# frozen_string_literal: true
require 'csv'

class CscrmDataCollection2 < ApplicationRecord
  self.table_name = "cscrm_data_collections2"

  include AASM

  belongs_to :user
  belongs_to :organization

  validates :year, presence: true
  validates :quarter, presence: true

  aasm do
    state :draft, initial: true
    state :submitted
    state :published
    state :archived

    event :submit do
      transitions from: %i[draft], to: :submitted
    end

    event :publish do
      transitions from: :submitted, to: :published
    end

    event :archive do
      transitions from: [:published], to: :archived
    end

    event :reset do
      transitions to: :draft
    end
  end

  #
  # Define the Questions
  #

  def self.question_1
    {
      text: "An interdisciplinary enterprise-wide Department or Agency team is established for SCRM as evidenced by periodic
meetings and deliverables demonstrating team contributions.",
      number: 1,
      field: :interdisciplinary_team,
      options: implementation_status_options,
    }
  end

  def self.question_2
    {
      text: "A CSCRM PMO or equivalent exists with a defined charter.",
      number: 2,
      field: :pmo_established,
      options: implementation_status_options,
    }
  end

  def self.question_3
    {
      text: "Established Enterprise-wide SCRM policy.",
      number: 3,
      field: :established_policy,
      options: implementation_status_options,
    }
  end

  def self.question_4
    {
      text: "Acquisition procedures are documented that require cybersecurity supply chain risks are addressed throughout the procurement and contract management lifecycle for ICTS-related purchases.",
      number: 4,
      field: :supply_chain_acquisition_procedures,
      options: interdisciplinary_team_established_options,
    }
  end

  def self.question_5
    {
      text: "Identified or secured funding for C-SCRM program functions for Initial Operating Capability.",
      number: 5,
      field: :funding,
      options: funding_for_initial_operating_capability_options,
    }
  end

  def self.question_6
    {
      text: "Identified and available PMO staff (core and extended teams)",
      number: 6,
      field: :identified_staff,
      options: funding_for_initial_operating_capability_options,
    }
  end

  def self.question_7
    {
      text: "Established agency-wide SCRM strategy and implementation plan for providing the organizational context in which risk-based decisions will be made",
      number: 7,
      field: :strategy_plan,
      options: implementation_status_options,
    }
  end

  def self.question_8
    {
      text: "Governance structure has been established that integrates with the Enterprise Risk Management Function",
      number: 8,
      field: :governance_structure,
      options: enterprise_risk_management_function_established_options,

    }
  end

  def self.question_9
    {
      text: "CSCRM roles and functional responsibilities clearly defined for key personnel (minimally, PMO, the acquisition workforce and IT Security personnel) and documented in one or more official agency records (e.g., position descriptions, organizational directives)",
      number: 9,
      field: :clearly_defined_roles,
      options: roles_and_responsibilities_options,
    }
  end

  def self.question_10
    {
      text: "Identified missions, assets, systems,
processes, data and suppliers (e.g., HVAs, critical suppliers, mission- essential functions)",
      number: 10,
      field: :identified_assets_and_essential_functions,
      options: missions_identified_options,
    }
  end

  def self.question_11
    {
      text: "Established process to prioritize by
criticality",
      number: 11,
      field: :prioritization_process,
      options: implementation_status_options,
    }
  end

  def self.question_12
    {
      text: " C-SCRM considerations in procurement processes and actions",
      number: 12,
      field: :considerations_in_procurement_processes,
      options: considerations_in_procurement_processes_options,
    }
  end

  def self.question_13
    {
      text: "A methodology for conducting Supply Chain Risk Assessment is documented.",
      number: 13,
      field: :documented_methodology,
      options: yes_no_in_development,
    }
  end

  def self.question_14
    {
      text: "Conducts Supply Chain Risk Assessments (SCRA) for prioritized products and services",
      number: 14,
      field: :conducts_scra_for_prioritized_products_and_services,
      options: conducts_scra_for_prioritized_products_and_services_options,
    }
  end

  def self.question_15
    {
      text: "Personnel with roles and responsibilities for SCRM have completed general (basic) SCRM training or will complete training by the end of this Fiscal Year",
      number: 15,
      field: :personnel_required_to_complete_training,
      options: training_options,
    }
  end

  def self.question_16
    {
      text: "Established process for internal and exchanging information sharing with the Federal Acquisition Security Council (FASC)",
      number: 16,
      field: :established_process_information_sharing_with_fasc,
      options: established_process_information_sharing_options,
    }
  end

  def self.question_17
    {
      text: "Conducts SCRA of key suppliers of ICT systems and services identified in organizational COOP and Recovery Plans to include mitigations to improve resiliency/address accessed risk in these plans",
      number: 17,
      field: :cybersecurity_supply_chain_risk_considerations,
      options: cybersecurity_supply_chain_risk_considerations_options,
    }
  end
  def self.question_18
    {
      text: "Process to detect, report, and remediate counterfeit non-conforming ICT products prior to deployment is defined and documented",
      number: 18,
      field: :process_for_product_authenticity,
      options: implementation_status_options,
    }
  end

  def self.question_19
    {
      text: "C-SCRM security controls are selected, tailored as appropriate, and implements and distinctly and clearly incorporated into system security plans.",
      number: 19,
      field: :cscrm_controls_incorporated_into_ssp,
      options: cscrm_controls_incorporated_into_ssp_options,
    }
  end




  #
  # Define the Radio button text and values
  #

  def self.implementation_status_options
    {
      "No" => 0,
      "Partial/In-process" => 1,
      "Plan Developed" => 2,
      "Yes" => 3
    }
  end

  def self.cscrm_controls_incorporated_into_ssp_options
    {
      "No" => 0,
      "Selection In-process" => 1,
      "Partially implemented" => 2,
      "Yes" => 3
    }
  end

  def self.interdisciplinary_team_established_options
    {
      "No" => 0,
      "Procedures are being developed" => 1,
      "Procedures are in place that partially meet this benchmark" => 2,
      "Yes" => 3,
    }
  end

  def self.funding_for_initial_operating_capability_options
    {
      "Not Identified or secured" => 0,
      "Identified but not secured" => 1,
      "Partially secured" => 2,
      "Fully identified and secured" => 3,
    }
  end

   def self.missions_identified_options
    {
      'Not identified' => 0,
      'Mission Functions Identified' => 1,
      'Existing Asset Inventory' => 2,
      'Existing Systems Inventory' => 3,
      'Existing Supplier Inventory/List' => 4,
      'Critical Mission Functions identified' => 5,
      'Critical Assets Identified' => 6,
      'Critical Systems Identified' => 7,
      'Critical Suppliers Identified' => 8
    }
  end

  def self.roles_and_responsibilities_options
    {
      "Not defined" => 0,
      "Partially defined for PMO" => 1,
      "Fully defined for PMO" => 2,
      "Partially defined for Acquisition Workforce Personnel" => 3,
      "Partially defined for IT/Information Security Personnel" => 4,
      "Fully defined for Acquisition Workforce Personnel" => 5,
      "Fully defined for IT/Information Security Personnel" => 6,
      "Partially or Fully Defined for Other Personnel" => 7
    }
  end

  def self.cybersecurity_supply_chain_risk_considerations_options
    {
      'Not considered' => 0,
      'Critical Suppliers are identified in COOP and Recovery plans' => 1,
      'Business Impact Analysis considers supplier and product dependency risks and resiliency requirements' => 2,
      'SCRAs are conducted for critical suppliers' => 3,
      'Mitigations to improve resilience/address assessed risks  associated with critical suppliers are identified and implemented' => 4
    }
  end



  # def self.implementation_status_options
  #   {
  #     0 => "No",
  #     1 => "Partial/In-process",
  #     2 => "Plan Developed",
  #     3 => "Yes"
  #   }
  # end



  ## OLD OPTIONS BELOW...........................................

  def self.agency_roles_options
    {
      "No" => 0,
      "Partial/In-process" => 1,
      "Plan Developed" => 2,
      "Yes" => 3
    }
  end

  def self.training_options
    {
      "No" => 0,
      "No, Training not available" => 2,
      "Partial" => 3,
      "Yes" => 1
    }
  end

  def self.leadership_roles_options
    {
      "Not defined" => 0,
      "Partially defined" => 1,
      "Defined" => 2,
      "Defined and designated" => 3
    }
  end

  def self.stakeholder_champion_identified_options
    {
      "Not identified" => 0,
      "A C-SCRM “Champion” (or, C-SCRM Executive Sponsor, C-SCRM Lead Official, etc.) is identified" => 0,
      "C-SCRM PMO is identified to provide leadership" => 0,
      "C-SCRM Team (e.g, Council, Committee (etc.) is identified to provide leadership" => 0,
      "Not applicable (implementation complete)" => 0,
      "Other" => 0
    }
  end


  def self.pmo_established_options
    {
      "No" => 0,
      "Partial/In-process" => 1,
      "Plan Developed" => 2,
      "Yes" => 3,
    }
  end

  def self.enterprise_risk_management_function_established_options
    {
      "Not established" => 0,
      "Executive Board evaluates risks across enterprise" => 1,
      "CSCRM program requirements are defined and managed" => 2,
      "Analysis of the likelihood and impact of potential supply chain cybersecurity threats" => 3
    }
  end

  def self.considerations_in_procurement_processes_options
    {
      'Not considered' => 1,
      'Acquisition Strategy' => 2,
      'Acquisition Plan' => 3,
      'Requirements language' => 4,
      'Source Selection evaluation factors' => 5,
      'Quality Assurance Surveillance Plan (QASP)' => 6,
      'Supplier (vendor) Risk Assessment' => 7,
      'Compliance clauses' => 8,
      'Other' => 9
    }
  end

  def self.yes_no_in_development
    {
      'No' => 0,
      'In development' => 2,
      'Yes' => 1,
    }
  end

  def self.conducts_scra_for_prioritized_products_and_services_options
    {
      'Not conducted' => 0,
      'Conducted for some prioritized products' => 1,
      'Conducted for some prioritized services' => 2,
      'Conducted for all prioritized products' => 3,
      'Conducted for all prioritized services' => 4
    }
  end

  def self.established_process_information_sharing_options
    {
      "Not established" => 0,
      "Internal process partially developed/In process" => 1,
      "Internal process (only) established" => 2,
      "Internal process established" => 3,
      "FASC information sharing process planned or in process" => 4,
      "Internal and FASC information sharing processes established" => 5
    }
  end


  #
  #
  # Custom logic applied to fields for data export
  # example: 8 checkbox values being consolidated into a value between 1-3
  #
  #

  def self.export_conversion_question_9(field)
    return nil if !field || field.length == 1

    # 0 = Not Defined
    # 1 = All Partial
    # 2 = Partial and Full
    # 3 = All Fully defined (“Other” was included for informational purposes)

    question_option_selections = YAML.load(field) # parse the string encoded as an array, to an array
    question_option_selections_without_not_defined = question_option_selections - ["Not defined"] # remove Not defined option

    if question_option_selections_without_not_defined.include?("Fully defined for PMO") &&
      question_option_selections_without_not_defined.include?("Fully defined for Acquisition Workforce Personnel") &&
      question_option_selections_without_not_defined.include?("Fully defined for IT/Information Security Personnel")
      3
    elsif question_option_selections_without_not_defined.include?("Partially defined for Acquisition Workforce Personnel") &&
        question_option_selections_without_not_defined.include?("Partially defined for IT/Information Security Personnel") &&
        question_option_selections_without_not_defined.include?("Partially defined for IT/Information Security Personnel") &&
        question_option_selections_without_not_defined.include?("Partially or Fully Defined for Other Personnel")
      1
    elsif (question_option_selections_without_not_defined.include?("Partially defined for Acquisition Workforce Personnel") ||
        question_option_selections_without_not_defined.include?("Partially defined for IT/Information Security Personnel") ||
        question_option_selections_without_not_defined.include?("Partially defined for IT/Information Security Personnel") ||
        question_option_selections_without_not_defined.include?("Partially or Fully Defined for Other Personnel") ) &&
        (question_option_selections_without_not_defined.include?("Fully defined for PMO") ||
        question_option_selections_without_not_defined.include?("Fully defined for Acquisition Workforce Personnel") ||
        question_option_selections_without_not_defined.include?("Fully defined for IT/Information Security Personnel") )
      2
    elsif question_option_selections.include?("Not defined")
      0
    else
      "not scored"
    end
  end

  def self.export_conversion_question_10(field)
    return nil if !field || field.length == 1

    # 0 = Not Identified
    # 1 = 1 or 2 identified
    # 2 = All but suppliers identified
    # 3 = All identified
    # Note: Critical item selections not scored, for info only; however,
    # If critical items were selected, assumption was that items had been identified

    question_option_selections = YAML.load(field) # parse the string encoded as an array, to an array
    question_option_selections_without_not_identified = question_option_selections - ["Not identified"] # remove Not Identified option
    question_option_selections_without_suppliers = question_option_selections_without_not_identified - ["Critical Suppliers Identified"] # remove Not Identified and Suppliers option

    if question_option_selections_without_not_identified.size == 8 # if all are selected
      3
    elsif question_option_selections_without_suppliers.size == 7
      2
    elsif (1..6).include?(question_option_selections_without_suppliers.size)
      1
    elsif question_option_selections.include?("Not identified")
      0
    else
      "not scored"
    end
  end

  def self.export_conversion_question_12(field)
    return nil if !field || field.length == 1

    # 0 = Not Considered
    # 1 = up to 2 selections OR Other
    # 2 = 3 to 6 selections
    # 3 = All

    question_option_selections = YAML.load(field)
    question_option_selections_without_not_considered = question_option_selections - ["Not considered"]
    question_option_selections_without_other = question_option_selections_without_not_considered - ["Other"]

    if question_option_selections_without_other.size == 7 # if all are selected
      3
    elsif (3..6).include?(question_option_selections_without_other.size)
      2
    elsif (1..2).include?(question_option_selections_without_other.size)
      1
    elsif question_option_selections == ["Other"]
      1
    elsif question_option_selections.include?("Not considered")
      0
    else
      "not scored"
    end
  end

  def self.export_conversion_question_14(field)
    return nil if !field || field.length == 1

    # 0 = Not Considered
    # 1 = Some Products and/or Services
    # 2 = Some Products/All Services or All
    # Products/Some Services
    # 3 = All Product and Services
    # Note: If 1 “all” option selected score = 2

    question_option_selections = YAML.load(field)
    question_option_selections_without_not_conducted = question_option_selections - ["Not conducted"]

    if question_option_selections_without_not_conducted.include?("Conducted for all prioritized products") &&
        question_option_selections_without_not_conducted.include?("Conducted for all prioritized services")
      3
    elsif question_option_selections_without_not_conducted.include?("Conducted for all prioritized products") ||
        question_option_selections_without_not_conducted.include?("Conducted for all prioritized services")
      2
    elsif question_option_selections_without_not_conducted.include?("Conducted for some prioritized products") ||
      question_option_selections_without_not_conducted.include?("Conducted for some prioritized services")
      1
    elsif question_option_selections.include?("Not conducted")
      0
    else
      "not scored"
    end
  end

  def self.export_conversion_question_16(field)
    # 0 = Not established
    # 1 = Partial/in-Process Internal process
    # 2 = Internal Process established and/or FASC process planned/in-process
    # 3 = Internal and FASC process established

    if field == "5"
      3
    elsif field == "2" ||
      field == "3" ||
      field == "4"
      2
    elsif field == "1"
      1
    elsif field == "0"
      0
    else
      "not scored"
    end
  end

  def self.export_conversion_question_17(field)
    return nil if !field || field.length == 1

    # 0 = Not Considered;
    # 1 = Response option(s), other than SCRAs;
    # 2 = Response options includes “SCRAs” but not “mitigations”
    # 3 = ”SCRAs” and “Mitigations” options selected

    question_option_selections = YAML.load(field)

    if question_option_selections.include?("SCRAs are conducted for critical suppliers") &&
      question_option_selections.include?("Mitigations to improve resilience/address assessed risks  associated with critical suppliers are identified and implemented")
      3
    elsif question_option_selections.include?("SCRAs are conducted for critical suppliers") &&
      !question_option_selections.include?("Mitigations to improve resilience/address assessed risks  associated with critical suppliers are identified and implemented")
      2
    elsif question_option_selections.include?("Critical Suppliers are identified in COOP and Recovery plans") ||
      question_option_selections.include?("Business Impact Analysis considers supplier and product dependency risks and resiliency requirements") ||
      question_option_selections.include?("Mitigations to improve resilience/address assessed risks  associated with critical suppliers are identified and implemented")
      1
    elsif question_option_selections.include?("Not considered")
      0
    else
      "not scored"
    end
  end

  #
  # end custom export logic
  #


  def self.to_csv
    collections = CscrmDataCollection2.order('year, quarter')

    attributes = [
      "id",
      "organization_id",
      "organization_name",
      "bureau_id",
      "year",
      "quarter",
      "user_id",
      "user_email",

      "aasm_state",
      "reflection",
      "rating",

      "interdisciplinary_team_value",
      "interdisciplinary_team",
      "interdisciplinary_team_comments",
      "pmo_established_value",
      "pmo_established",
      "pmo_established_comments",
      "established_policy_value",
      "established_policy",
      "established_policy_comments",
      "supply_chain_acquisition_procedures_value",
      "supply_chain_acquisition_procedures",
      "supply_chain_acquisition_procedures_comments",
      "funding_value",
      "funding",
      "funding_comments",
      "identified_staff_value",
      "identified_staff",
      "identified_staff_comments",
      "strategy_plan_value",
      "strategy_plan",
      "strategy_plan_comments",
      "governance_structure_value",
      "governance_structure",
      "governance_structure_comments",
      "clearly_defined_roles_value",
      "clearly_defined_roles_translated_value",
      "clearly_defined_roles_comments",
      "identified_assets_and_essential_functions_value",
      "identified_assets_and_essential_functions_translated_value",
      "identified_assets_and_essential_functions_comments",
      "prioritization_process_value",
      "prioritization_process",
      "prioritization_process_comments",
      "considerations_in_procurement_processes",
      "considerations_in_procurement_processes_value",
      "considerations_in_procurement_processes_translated_value",
      "considerations_in_procurement_processes_comments",
      "documented_methodology_value",
      "documented_methodology",
      "documented_methodology_comments",
      "conducts_scra_for_prioritized_products_and_services",
      "conducts_scra_for_prioritized_products_and_services_value",
      "conducts_scra_for_prioritized_products_and_services_translated_value",
      "conducts_scra_for_prioritized_products_and_services_comments",
      "personnel_required_to_complete_training_value",
      "personnel_required_to_complete_training",
      "personnel_required_to_complete_training_comments",
      "established_process_information_sharing_with_fasc",
      "established_process_information_sharing_with_fasc_value",
      "established_process_information_sharing_with_fasc_translated_value",
      "established_process_information_sharing_with_fasc_comments",
      "cybersecurity_supply_chain_risk_considerations_value",
      "cybersecurity_supply_chain_risk_considerations_translated_value",
      "cybersecurity_supply_chain_risk_considerations_comments",
      "process_for_product_authenticity_value",
      "process_for_product_authenticity",
      "process_for_product_authenticity_comments",
      "cscrm_controls_incorporated_into_ssp_value",
      "cscrm_controls_incorporated_into_ssp",
      "cscrm_controls_incorporated_into_ssp_comments",
      "comments",
      "created_at",
      "updated_at"
    ]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      collections.each do |collection|
        csv << [
          collection.id,
          collection.organization_id,
          collection.organization.name,
          collection.bureau_id,
          collection.year,
          collection.quarter,
          collection.user_id,
          collection.user.email,

          collection.aasm_state,
          # collection.integrity_hash,
          collection.reflection,
          collection.rating,

          CscrmDataCollection2.question_1[:options].key(collection.interdisciplinary_team.to_i),
          collection.interdisciplinary_team,
          collection.interdisciplinary_team_comments,
          CscrmDataCollection2.question_2[:options].key(collection.pmo_established.to_i),
          collection.pmo_established,
          collection.pmo_established_comments,
          CscrmDataCollection2.question_3[:options].key(collection.established_policy.to_i),
          collection.established_policy,
          collection.established_policy_comments,
          CscrmDataCollection2.question_4[:options].key(collection.supply_chain_acquisition_procedures.to_i),
          collection.supply_chain_acquisition_procedures,
          collection.supply_chain_acquisition_procedures_comments,
          CscrmDataCollection2.question_5[:options].key(collection.funding.to_i),
          collection.funding,
          collection.funding_comments,
          CscrmDataCollection2.question_6[:options].key(collection.identified_staff.to_i),
          collection.identified_staff,
          collection.identified_staff_comments,
          CscrmDataCollection2.question_7[:options].key(collection.strategy_plan.to_i),
          collection.strategy_plan,
          collection.strategy_plan_comments,
          CscrmDataCollection2.question_8[:options].key(collection.governance_structure.to_i),
          collection.governance_structure,
          collection.governance_structure_comments,

          collection.clearly_defined_roles,
          export_conversion_question_9(collection.clearly_defined_roles),
          collection.clearly_defined_roles_comments,

          collection.identified_assets_and_essential_functions,
          export_conversion_question_10(collection.identified_assets_and_essential_functions),
          collection.identified_assets_and_essential_functions_comments,

          CscrmDataCollection2.question_11[:options].key(collection.prioritization_process.to_i),
          collection.prioritization_process,
          collection.prioritization_process_comments,

          CscrmDataCollection2.question_12[:options].key(collection.considerations_in_procurement_processes.to_i),
          collection.considerations_in_procurement_processes,
          export_conversion_question_12(collection.considerations_in_procurement_processes),
          collection.considerations_in_procurement_processes_comments,

          CscrmDataCollection2.question_13[:options].key(collection.documented_methodology.to_i),
          collection.documented_methodology,
          collection.documented_methodology_comments,

          CscrmDataCollection2.question_14[:options].key(collection.conducts_scra_for_prioritized_products_and_services.to_i),
          collection.conducts_scra_for_prioritized_products_and_services,
          export_conversion_question_14(collection.conducts_scra_for_prioritized_products_and_services),
          collection.conducts_scra_for_prioritized_products_and_services_comments,

          CscrmDataCollection2.question_15[:options].key(collection.personnel_required_to_complete_training.to_i),
          collection.personnel_required_to_complete_training,
          collection.personnel_required_to_complete_training_comments,

          CscrmDataCollection2.question_16[:options].key(collection.established_process_information_sharing_with_fasc.to_i),
          collection.established_process_information_sharing_with_fasc,
          export_conversion_question_16(collection.established_process_information_sharing_with_fasc),
          collection.established_process_information_sharing_with_fasc_comments,

          collection.cybersecurity_supply_chain_risk_considerations,
          export_conversion_question_17(collection.cybersecurity_supply_chain_risk_considerations),
          collection.cybersecurity_supply_chain_risk_considerations_comments,

          CscrmDataCollection2.question_18[:options].key(collection.process_for_product_authenticity.to_i),
          collection.process_for_product_authenticity,
          collection.process_for_product_authenticity_comments,
          CscrmDataCollection2.question_19[:options].key(collection.cscrm_controls_incorporated_into_ssp.to_i),
          collection.cscrm_controls_incorporated_into_ssp,
          collection.cscrm_controls_incorporated_into_ssp_comments,
          collection.comments,

          collection.created_at,
          collection.updated_at,
        ]
      end
    end
  end

end
