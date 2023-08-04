
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
      options: implementation_status_options,
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
      text: "Personnel required to complete general or role-based SCRM training requirements",
      number: 15,
      field: :personnel_required_to_complete_training,
      options: implementation_status_options,
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
      text: "Cybersecurity supply chain risk and resiliency considerations are incorporated into organizational COOP and Recovery Plans",
      number: 17,
      field: :cybersecurity_supply_chain_risk_considerations,
      options: implementation_status_options,
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

      "interdisciplinary_team",
      "interdisciplinary_team_comments",
      "pmo_established",
      "pmo_established_comments",
      "established_policy",
      "established_policy_comments",
      "supply_chain_acquisition_procedures",
      "supply_chain_acquisition_procedures_comments",
      "funding",
      "funding_comments",
      "identified_staff",
      "identified_staff_comments",
      "strategy_plan",
      "strategy_plan_comments",
      "governance_structure",
      "governance_structure_comments",
      "clearly_defined_roles",
      "clearly_defined_roles_comments",
      "identified_assets_and_essential_functions",
      "identified_assets_and_essential_functions_comments",
      "prioritization_process",
      "prioritization_process_comments",
      "considerations_in_procurement_processes",
      "considerations_in_procurement_processes_comments",
      "documented_methodology",
      "documented_methodology_comments",
      "conducts_scra_for_prioritized_products_and_services",
      "conducts_scra_for_prioritized_products_and_services_comments",
      "personnel_required_to_complete_training",
      "personnel_required_to_complete_training_comments",
      "established_process_information_sharing_with_fasc",
      "established_process_information_sharing_with_fasc_comments",
      "cybersecurity_supply_chain_risk_considerations",
      "cybersecurity_supply_chain_risk_considerations_comments",
      "process_for_product_authenticity",
      "process_for_product_authenticity_comments",
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

          collection.interdisciplinary_team,
          collection.interdisciplinary_team_comments,
          collection.pmo_established,
          collection.pmo_established_comments,
          collection.established_policy,
          collection.established_policy_comments,
          collection.supply_chain_acquisition_procedures,
          collection.supply_chain_acquisition_procedures_comments,
          collection.funding,
          collection.funding_comments,
          collection.identified_staff,
          collection.identified_staff_comments,
          collection.strategy_plan,
          collection.strategy_plan_comments,
          collection.governance_structure,
          collection.governance_structure_comments,
          CscrmDataCollection2.question_9[:options].key(collection.clearly_defined_roles.to_i),
          collection.clearly_defined_roles_comments,
          CscrmDataCollection2.question_10[:options].key(collection.identified_assets_and_essential_functions.to_i),
          collection.identified_assets_and_essential_functions_comments,
          collection.prioritization_process,
          collection.prioritization_process_comments,
          CscrmDataCollection2.question_12[:options].key(collection.considerations_in_procurement_processes.to_i),
          collection.considerations_in_procurement_processes_comments,
          collection.documented_methodology,
          collection.documented_methodology_comments,
          CscrmDataCollection2.question_14[:options].key(collection.conducts_scra_for_prioritized_products_and_services.to_i),
          collection.conducts_scra_for_prioritized_products_and_services_comments,
          collection.personnel_required_to_complete_training,
          collection.personnel_required_to_complete_training_comments,
          collection.established_process_information_sharing_with_fasc,
          collection.established_process_information_sharing_with_fasc_comments,
          CscrmDataCollection2.question_17[:options].key(collection.cybersecurity_supply_chain_risk_considerations.to_i),
          collection.cybersecurity_supply_chain_risk_considerations_comments,
          collection.process_for_product_authenticity,
          collection.process_for_product_authenticity_comments,
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
