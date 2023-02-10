# frozen_string_literal: true
require 'csv'

class CscrmDataCollection < ApplicationRecord
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

  def self.question_1
    {
      text: "The Agency’s role in SCRM is identified and communicated",
      number: 1,
      field: :agency_roles,
    }
  end

  def self.question_2
    {
      text: "Senior leadership roles, responsibilities and accountability for C-SCRM are defined",
      number: 2,
      field: :leadership_roles,
    }
  end

  def self.question_3
    {
      text: "A CSCRM Champion has been identified for your Agency",
      number: 3,
      field: :stakeholder_champion_identified,
    }
  end

  def self.question_4
    {
      text: "Establishment of an interdisciplinary enterprise-wide Department or Agency team including SMEs from IT, Logistics, Procurement, Cybersecurity, Mission, Legal, ERM and CFO officials to manage and mitigate risk in the C-SCRM supply chain",
      number: 4,
      field: :interdisciplinary_team_established,
    }
  end

  def self.question_5
    {
      text: "Establishment of CSCRM PMO or equivalent",
      number: 5,
      field: :pmo_established,
    }
  end

  def self.question_6
    {
      text: "Established Enterprise-wide SCRM policy",
      number: 6,
      field: :enterprise_wide_scrm_policy_established,
    }
  end

  def self.question_7
    {
      text: "Identified or secured funding for CSCRM program functions for Initial Operating Capability",
      number: 7,
      field: :funding_for_initial_operating_capability,
    }
  end

  def self.question_8
    {
      text: "Identified and available staff",
      number: 8,
      field: :staffing,
    }
  end

  def self.question_9
    {
      text: "Established agency-wide SCRM strategy and implementation plan for providing the organizational context in which risk-based decisions will be made",
      number: 9,
      field: :agency_wide_scrm_strategy_and_implementation_plan_established,
    }
  end

  def self.question_10
    {
      text: "Governance structure has been established that integrates with the Enterprise Risk Management Function",
      number: 10,
      field: :enterprise_risk_management_function_established,
    }
  end

  def self.question_11
    {
      text: "C-SCRM roles and functional responsibilities clearly defined for key C-SCRM personnel (minimally, PMO, acquisition
    workforce and IT/Information Security personnel",
      number: 11,
      field: :roles_and_responsibilities,
    }
  end

  def self.question_12
    {
      text: "Identified missions, assets, systems, processes, data and suppliers (e.g., HVAs, critical suppliers,
    mission-essential functions)",
      number: 12,
      field: :missions_identified,
    }
  end

  def self.question_13
    {
      text: "Established process to prioritize by criticality",
      number: 13,
      field: :prioritization_process,
    }
  end

  def self.question_14
    {
      text: " C-SCRM considerations in procurement processes and actions",
      number: 14,
      field: :considerations_in_procurement_processes,
    }
  end

  def self.question_15
    {
      text: "Conducts Supply Chain Risk Assessments (SCRA) for prioritized products and services",
      number: 15,
      field: :conducts_scra_for_prioritized_products_and_services,
    }
  end

  def self.question_16
    {
      text: "Personnel required to complete general or role-based SCRM training requirements",
      number: 16,
      field: :personnel_required_to_complete_training,
    }
  end

  def self.question_17
    {
      text: "Established process for internal and exchanging information sharing with the Federal Acquisition Security Council (FASC)",
      number: 17,
      field: :established_process_information_sharing_with_fasc,
    }
  end

  def self.question_18
    {
      text: "Cybersecurity supply chain risk and resiliency considerations are incorporated into organizational COOP and Recovery Plans",
      number: 18,
      field: :cybersecurity_supply_chain_risk_considerations,
    }
  end


  def self.agency_roles_options
    [
      "No",
      "Partial/In-process",
      "Plan Developed",
      "Yes"
    ]
  end

  def self.leadership_roles_options
    [
      "Not defined",
      "Partially defined",
      "Defined",
      "Defined and designated"
    ]
  end

  def self.stakeholder_champion_identified_options
    [
      "Not identified",
      "A C-SCRM “Champion” (or, C-SCRM Executive Sponsor, C-SCRM Lead Official, etc.) is identified",
      "C-SCRM PMO is identified to provide leadership",
      "C-SCRM Team (e.g, Council, Committee (etc.) is identified to provide leadership",
      "Not applicable (implementation complete)",
      "Other"
    ]
  end

  def self.interdisciplinary_team_established_options
    [
      "No",
      "Partial/In-process",
      "Plan Developed",
      "Yes",
    ]
  end

  def self.pmo_established_options
    [
      "No",
      "Partial/In-process",
      "Plan Developed",
      "Yes",
    ]
  end

  def self.enterprise_wide_scrm_policy_established_options
    [
      "No",
      "Partial/In-process",
      "Plan Developed",
      "Yes",
    ]
  end

  def self.funding_for_initial_operating_capability_options
    [
      "Not Identified or secured",
      "Identified but not secured",
      "Partially secured",
      "Fully identified and secured",
    ]
  end

  def self.staffing_options
    [
      "Not Identified or secured",
      "Identified but not secured",
      "Partially secured",
      "Fully identified and secured",
    ]
  end

  def self.agency_wide_scrm_strategy_and_implementation_plan_options
    [
      "No",
      "Partial/In-process",
      "Plan Developed",
      "Yes",
    ]
  end

  def self.enterprise_risk_management_function_established_options
    [
      "Not established",
      "Executive Board evaluates risks across enterprise",
      "CSCRM program requirements are defined and managed",
      "Analysis of the likelihood and impact of potential supply chain cybersecurity threats"
    ]
  end

  def self.roles_and_responsibilities_options
    [
      "Not defined",
      "Partially defined for PMO",
      "Fully defined for PMO",
      "Partially defined for Acquisition Workforce Personnel",
      "Partially defined for IT/Information Security Personnel",
      "Fully defined for Acquisition Workforce Personnel",
      "Fully defined for IT/Information Security Personnel",
      "Partially or Fully Defined for Other Personnel"
    ]
  end

  def self.missions_identified_options
    [
      'Not identified',
      'Mission Functions Identified',
      'Existing Asset Inventory',
      'Existing Systems Inventory',
      'Existing Supplier Inventory/List',
      'Critical Mission Functions identified',
      'Critical Assets Identified',
      'Critical Systems Identified',
      'Critical Suppliers Identified'
    ]
  end

  def self.prioritization_process_options
    [
      "No",
      "Partial/In-process",
      "Plan Developed",
      "Yes"
    ]
  end

  def self.considerations_in_procurement_processes_options
    [
      'Not considered',
      'Acquisition Strategy',
      'Acquisition Plan',
      'Requirements language',
      'Source Selection evaluation factors',
      'Quality Assurance Surveillance Plan (QASP)',
      'Supplier (vendor) Risk Assessment',
      'Compliance clauses',
      'Other'
    ]
  end

  def self.conducts_scra_for_prioritized_products_and_services_options
    [
      'Not conducted',
      'Conducted for some prioritized products',
      'Conducted for some prioritized services',
      'Conducted for all prioritized products',
      'Conducted for all prioritized services'
    ]
  end

  def self.personnel_required_to_complete_training_options
    [
      'Not identified',
      'Partially identified',
      'Identified for “General”',
      'Identified for “Role-based”',
      'General training currently  available',
      'Role-based training currently available'
    ]
  end

  def self.established_process_information_sharing_options
    [
      "Not established",
      "Internal process partially developed/In process",
      "Internal process (only) established",
      "Internal process established",
      "FASC information sharing process planned or in process",
      "Internal and FASC information sharing processes established"
    ]
  end

  def self.cybersecurity_supply_chain_risk_considerations_options
    [
      'Not considered',
      'Critical Suppliers are identified in COOP and Recovery plans',
      'Business Impact Analysis considers supplier and product dependency risks and resiliency requirements',
      'SCRAs are conducted for critical suppliers',
      'Mitigations to improve resilience/address assessed risks  associated with critical suppliers are identified and implemented'
    ]
  end

  def self.to_csv
    collections = CscrmDataCollection.order('year, quarter')

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
      "leadership_roles",
      "stakeholder_champion_identified",
      "pmo_established",
      "interdisciplinary_team_established",
      "enterprise_risk_management_function_established",
      "enterprise_wide_scrm_policy_established",
      "agency_wide_scrm_strategy_and_implementation_plan_established",
      "funding_for_initial_operating_capability",
      "staffing",
      "roles_and_responsibilities",
      "missions_identified",
      "prioritization_process",
      "considerations_in_procurement_processes",
      "conducts_scra_for_prioritized_products_and_services",
      "personnel_required_to_complete_training",
      "established_process_information_sharing_with_fasc",
      "cybersecurity_supply_chain_risk_considerations",
      "integrity_hash",
      "reflection",
      "rating",
      "agency_roles",
      "agency_roles_comments",
      "stakeholder_champion_identified_comments",
      "interdisciplinary_team_established_comments",
      "pmo_established_comments",
      "agency_wide_scrm_strategy_and_implementation_plan_comments",
      "enterprise_risk_management_function_established_comments",
      "roles_and_responsibilities_comments",
      "enterprise_wide_scrm_policy_established_comments",
      "funding_for_initial_operating_capability_comments",
      "staffing_comments",
      "missions_identified_comments",
      "prioritization_process_comments",
      "considerations_in_procurement_processes_comments",
      "conducts_scra_for_prioritized_products_and_services_comments",
      "established_process_information_sharing_with_fasc_comments",
      "general_comments",
      "bureau",
      "leadership_roles_comments",
      "personnel_required_comments",
      "cybersecurity_supply_chain_risk_comments",
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
          collection.leadership_roles,
          collection.stakeholder_champion_identified,
          collection.pmo_established,
          collection.interdisciplinary_team_established,
          collection.enterprise_risk_management_function_established,
          collection.enterprise_wide_scrm_policy_established,
          collection.agency_wide_scrm_strategy_and_implementation_plan_established,
          collection.funding_for_initial_operating_capability,
          collection.staffing,
          collection.roles_and_responsibilities,
          collection.missions_identified,
          collection.prioritization_process,
          collection.considerations_in_procurement_processes,
          collection.conducts_scra_for_prioritized_products_and_services,
          collection.personnel_required_to_complete_training,
          collection.established_process_information_sharing_with_fasc,
          collection.cybersecurity_supply_chain_risk_considerations,
          collection.integrity_hash,
          collection.reflection,
          collection.rating,
          collection.agency_roles,
          collection.agency_roles_comments,
          collection.stakeholder_champion_identified_comments,
          collection.interdisciplinary_team_established_comments,
          collection.pmo_established_comments,
          collection.agency_wide_scrm_strategy_and_implementation_plan_comments,
          collection.enterprise_risk_management_function_established_comments,
          collection.roles_and_responsibilities_comments,
          collection.enterprise_wide_scrm_policy_established_comments,
          collection.funding_for_initial_operating_capability_comments,
          collection.staffing_comments,
          collection.missions_identified_comments,
          collection.prioritization_process_comments,
          collection.considerations_in_procurement_processes_comments,
          collection.conducts_scra_for_prioritized_products_and_services_comments,
          collection.established_process_information_sharing_with_fasc_comments,
          collection.general_comments,
          collection.bureau,
          collection.leadership_roles_comments,
          collection.personnel_required_comments,
          collection.cybersecurity_supply_chain_risk_comments,
          collection.created_at,
          collection.updated_at
        ]        
      end
    end
  end

end
