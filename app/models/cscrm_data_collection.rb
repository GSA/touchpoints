# frozen_string_literal: true
require 'csv'

class CscrmDataCollection < ApplicationRecord
  belongs_to :organization

  validates :year, presence: true
  validates :quarter, presence: true


  def self.agency_roles_options
    [
      "No",
      "Plan Developed",
      "Partial/In-process",
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
      "Plan Developed",
      "Partial/In-process",
      "Yes",
      "Comments: if not yes explain",
    ]
  end

  def self.pmo_established_options
    [
      "No",
      "Plan Developed",
      "Partial/In-process",
      "Yes",
      "Comments: if not yes explain",
    ]
  end

  def self.enterprise_wide_scrm_policy_established_options
    [
      "No",
      "Plan Developed",
      "Partial/In-process",
      "Yes",
      "Comments: if not yes explain"
    ]
  end

  def self.funding_for_initial_operating_capability_options
    [
      "Not Identified or secured",
      "Identified by not secured",
      "Partially secured",
      "Fully identified and secured",
      "if not identified or secured explain"
    ]
  end

  def self.staffing_options
    [
      "Not Identified or secured",
      "Identified by not secured",
      "Partially secured",
      "Fully identified and secured",
      "if not identified or secured explain"
    ]
  end

  def self.agency_wide_scrm_strategy_and_implementation_plan_options
    [
      "No",
      "Plan Developed",
      "Partial/In-process",
      "Yes",
      "Comments: if not yes explain"
    ]
  end

  def self.enterprise_risk_management_function_established_options
    [
      "Not established",
      "Executive Board evaluates risks across enterprise",
      "CSCRM program requirements are defined and managed",
      "analysis of the likelihood and impact of potential supply chain cybersecurity threats"
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
      'Not identified (all)',
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
      "Plan Developed",
      "Partial/In-process",
      "Yes"
    ]
  end

  def self.considerations_in_procurement_processes_options
    [
      'Not considered',
      'Acquisition strategy',
      'Acquisition plan',
      'Requirements language',
      'Source Selection evaluation factors',
      'Quality Assurance Surveillance Plan (QASP)',
      'Supplier (vendor) risk assessment)',
      'Compliance clauses',
      'Other (Describe)'
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

    example_attributes = CscrmDataCollection.new.attributes
    attributes = example_attributes.keys

    CSV.generate(headers: true) do |csv|
      csv << attributes + ["Organization name"]

      collections.each do |collection|
        csv << attributes.map {
          |attr| collection.send(attr)
        } + [collection.organization.name]
      end
    end
  end

end
