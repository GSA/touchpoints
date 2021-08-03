class Collection < ApplicationRecord
  include AASM

  belongs_to :organization
  belongs_to :service
  belongs_to :user
  has_many :omb_cx_reporting_collections

  validates :year, presence: true
  validates :quarter, presence: true

  after_create :generate_supporting_elements

  validates :name, presence: true

  def generate_supporting_elements
    if self.name.include?("CX Quarterly")
      OmbCxReportingCollection.create!({
        collection: self,
        service_provided: "Description of your service"
      })
    end
  end

  def bureau
    "bureau"
  end

  def service_provided
    "service_provided"
  end

  def omb_control_number
    "omb_control_number"
  end

  aasm do
    state :draft, initial: true
    state :submitted
    state :published
    state :change_requested
    state :archived

    event :submit do
     transitions from: :draft, to: :submitted
    end

    event :publish do
     transitions from: :submitted, to: :published
    end

    event :request_change do
      transitions to: :change_requested
    end

    event :archive do
      transitions to: :archived
    end

    event :reset do
      transitions to: :draft
    end

  end

  def duplicate!(new_user:)
    new_collection = self.dup
    new_collection.user = new_user
    new_collection.name = "Copy of #{self.name}"
    new_collection.start_date = nil
    new_collection.end_date = nil
    new_collection.rating = nil
    new_collection.aasm_state = :draft
    new_collection.save

    # Loop OMB CX Reporting Collections to create them for new_collection
    self.omb_cx_reporting_collections.each do |omb_cx_reporting_collection|
      new_omb_cx_reporting_collection = omb_cx_reporting_collection.dup
      new_omb_cx_reporting_collection.collection = new_collection
      new_omb_cx_reporting_collection.volume_of_customers = 0
      new_omb_cx_reporting_collection.volume_of_customers_provided_survey_opportunity = 0
      new_omb_cx_reporting_collection.volume_of_respondents = 0
      new_omb_cx_reporting_collection.q1_1 = 0
      new_omb_cx_reporting_collection.q1_2 = 0
      new_omb_cx_reporting_collection.q1_3 = 0
      new_omb_cx_reporting_collection.q1_4 = 0
      new_omb_cx_reporting_collection.q1_5 = 0
      new_omb_cx_reporting_collection.q2_1 = 0
      new_omb_cx_reporting_collection.q2_2 = 0
      new_omb_cx_reporting_collection.q2_3 = 0
      new_omb_cx_reporting_collection.q2_4 = 0
      new_omb_cx_reporting_collection.q2_5 = 0
      new_omb_cx_reporting_collection.q3_1 = 0
      new_omb_cx_reporting_collection.q3_2 = 0
      new_omb_cx_reporting_collection.q3_3 = 0
      new_omb_cx_reporting_collection.q3_4 = 0
      new_omb_cx_reporting_collection.q3_5 = 0
      new_omb_cx_reporting_collection.q4_1 = 0
      new_omb_cx_reporting_collection.q4_2 = 0
      new_omb_cx_reporting_collection.q4_3 = 0
      new_omb_cx_reporting_collection.q4_4 = 0
      new_omb_cx_reporting_collection.q4_5 = 0
      new_omb_cx_reporting_collection.q5_1 = 0
      new_omb_cx_reporting_collection.q5_2 = 0
      new_omb_cx_reporting_collection.q5_3 = 0
      new_omb_cx_reporting_collection.q5_4 = 0
      new_omb_cx_reporting_collection.q5_5 = 0
      new_omb_cx_reporting_collection.q6_1 = 0
      new_omb_cx_reporting_collection.q6_2 = 0
      new_omb_cx_reporting_collection.q6_3 = 0
      new_omb_cx_reporting_collection.q6_4 = 0
      new_omb_cx_reporting_collection.q6_5 = 0
      new_omb_cx_reporting_collection.q7_1 = 0
      new_omb_cx_reporting_collection.q7_2 = 0
      new_omb_cx_reporting_collection.q7_3 = 0
      new_omb_cx_reporting_collection.q7_4 = 0
      new_omb_cx_reporting_collection.q7_5 = 0
      new_omb_cx_reporting_collection.q8_1 = 0
      new_omb_cx_reporting_collection.q8_2 = 0
      new_omb_cx_reporting_collection.q8_3 = 0
      new_omb_cx_reporting_collection.q8_4 = 0
      new_omb_cx_reporting_collection.q8_5 = 0
      new_omb_cx_reporting_collection.q9_1 = 0
      new_omb_cx_reporting_collection.q9_2 = 0
      new_omb_cx_reporting_collection.q9_3 = 0
      new_omb_cx_reporting_collection.q9_4 = 0
      new_omb_cx_reporting_collection.q9_5 = 0
      new_omb_cx_reporting_collection.q10_1 = 0
      new_omb_cx_reporting_collection.q10_2 = 0
      new_omb_cx_reporting_collection.q10_3 = 0
      new_omb_cx_reporting_collection.q10_4 = 0
      new_omb_cx_reporting_collection.q10_5 = 0
      new_omb_cx_reporting_collection.q11_1 = 0
      new_omb_cx_reporting_collection.q11_2 = 0
      new_omb_cx_reporting_collection.q11_3 = 0
      new_omb_cx_reporting_collection.q11_4 = 0
      new_omb_cx_reporting_collection.q11_5 = 0
      new_omb_cx_reporting_collection.save!
    end

    return new_collection
  end

  def totals
    @volume_of_customers = 0
    @volume_of_customers_provided_survey_opportunity = 0
    @volume_of_respondents = 0

    self.omb_cx_reporting_collections.each do |omb_cx_reporting_collection|
      @volume_of_customers += omb_cx_reporting_collection.volume_of_customers.to_i
      @volume_of_customers_provided_survey_opportunity += omb_cx_reporting_collection.volume_of_customers_provided_survey_opportunity.to_i
      @volume_of_respondents += omb_cx_reporting_collection.volume_of_respondents.to_i
    end

    {
      volume_of_customers: @volume_of_customers,
      volume_of_customers_provided_survey_opportunity: @volume_of_customers_provided_survey_opportunity,
      volume_of_respondents: @volume_of_respondents
    }
  end
end
