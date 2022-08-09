# frozen_string_literal: true

require 'csv'

class Form < ApplicationRecord
  include AASM

  belongs_to :user
  belongs_to :organization
  belongs_to :service, optional: true

  has_many :form_sections, dependent: :delete_all
  has_many :questions, dependent: :destroy, counter_cache: :questions_count
  has_many :submissions

  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles, primary_key: :form_id

  validates :name, presence: true
  validates :disclaimer_text, length: { in: 0..500, allow_blank: true }
  validates :delivery_method, presence: true
  validates :anticipated_delivery_count, numericality: true, allow_nil: true
  validate :omb_number_with_expiration_date
  validate :target_for_delivery_method
  validate :ensure_modal_text

  before_create :set_uuid
  after_create :create_first_form_section
  before_destroy :ensure_no_responses

  scope :non_templates, -> { where(template: false) }
  scope :templates, -> { where(template: true) }

  scope :non_archived, -> { where("aasm_state != 'archived'") }
  scope :archived, -> { where("aasm_state = 'archived'") }

  mount_uploader :logo, LogoUploader

  def target_for_delivery_method
    errors.add(:element_selector, "can't be blank for an inline form") if (delivery_method == 'custom-button-modal' || delivery_method == 'inline') && (element_selector == '')
  end

  def ensure_modal_text
    errors.add(:modal_button_text, "can't be blank for an modal form") if delivery_method == 'modal' && modal_button_text.empty?
  end

  def ensure_no_responses
    if submissions.count.positive?
      errors.add(:response_count_error, 'This form cannot be deleted because it has responses')
      throw(:abort)
    end
  end

  after_commit do |form|
    FormCache.invalidate(form.short_uuid)
  end

  DELIVERY_METHODS = [
    ['touchpoints-hosted-only', 'Hosted only on the Touchpoints site'],
    ['modal', 'Tab button & modal'],
    ['custom-button-modal', 'Custom button & modal'],
    ['inline', 'Embedded inline on your site'],
  ].freeze

  def suppress_submit_button
    questions.collect(&:question_type).include?('yes_no_buttons') || questions.collect(&:question_type).include?('custom_text_display')
  end

  def self.find_by_short_uuid(short_uuid)
    return nil unless short_uuid && short_uuid.length == 8

    where('uuid LIKE ?', "#{short_uuid}%").first
  end

  def self.find_by_legacy_touchpoints_id(id)
    return nil unless id && id.length < 4

    where(legacy_touchpoint_id: id).first
  end

  def self.find_by_legacy_touchpoints_uuid(short_uuid)
    return nil unless short_uuid && short_uuid.length == 8

    where('legacy_touchpoint_uuid LIKE ?', "#{short_uuid}%").first
  end

  def to_param
    short_uuid
  end

  def short_uuid
    uuid[0..7]
  end

  def send_notifications?
    notification_emails.present?
  end

  def create_first_form_section
    form_sections.create(title: (I18n.t 'form.page_1'), position: 1)
  end

  # def to_param
  #   short_uuid
  # end

  def short_uuid
    uuid[0..7]
  end

  aasm do
    state :in_development, initial: true
    state :live # manual
    state :archived # after End Date, or manual

    event :develop do
      transitions from: %i[live archived], to: :in_development
    end
    event :publish do
      transitions from: %i[in_development archived], to: :live
    end
    event :archive do
      transitions from: %i[in_development live], to: :archived
    end
    event :reset do
      transitions to: :in_development
    end
  end

  def transitionable_states
    aasm.states(permitted: true)
  end

  def all_states
    aasm.states
  end

  def duplicate!(new_user:)
    new_form = dup
    new_form.name = "Copy of #{name}"
    new_form.title = new_form.name
    new_form.survey_form_activations = 0
    new_form.response_count = 0
    new_form.questions_count = 0
    new_form.last_response_created_at = nil
    new_form.aasm_state = :in_development
    new_form.uuid = nil
    new_form.legacy_touchpoint_id = nil
    new_form.legacy_touchpoint_uuid = nil
    new_form.template = false
    new_form.user = new_user
    new_form.organization = new_user.organization
    new_form.save!

    # Manually remove the Form Section created with create_first_form_section
    new_form.form_sections.destroy_all

    # Loop Form Sections to create them for new_form
    form_sections.each do |section|
      new_form_section = section.dup
      new_form_section.form = new_form
      new_form_section.save

      # Loop Questions to create them for new_form and new_form_sections
      section.questions.each do |question|
        new_question = question.dup
        new_question.form = new_form
        new_question.form_section = new_form_section
        new_question.save

        # Loop Questions to create them for Questions
        question.question_options.each do |option|
          new_question_option = option.dup
          new_question_option.question = new_question
          new_question_option.save
        end
      end
    end

    new_form
  end

  def check_expired
    if !archived? && expiration_date.present? && (expiration_date <= Date.today)
      archive!
      Event.log_event(Event.names[:form_archived], 'Touchpoint', id, "Touchpoint #{name} archived on #{Date.today}")
    end
  end

  def self.archive_expired!
    Form.where("expiration_date is not null and expiration_date < NOW() and aasm_state <> 'archived'").find_each do |form|
      Event.log_event(Event.names[:form_archived], 'Form', form.uuid, "Form #{form.name} archived at #{DateTime.now}", 1)
      form.archive!
      UserMailer.form_status_changed(form:, action: 'archived').deliver_later
    end
  end

  def set_uuid
    self.uuid = SecureRandom.uuid if uuid.blank?
  end

  def deployable_form?
    live?
  end

  # returns javascript text that can be used standalone
  # or injected into a GTM Container Tag
  def touchpoints_js_string
    ApplicationController.new.render_to_string(partial: 'components/widget/fba', formats: :js, locals: { touchpoint: self })
  end

  def to_csv(start_date: nil, end_date: nil)
    non_flagged_submissions = submissions.non_flagged.where('created_at >= ?', start_date).where('created_at <= ?', end_date).order('created_at')
    return nil if non_flagged_submissions.blank?

    header_attributes = hashed_fields_for_export.values
    attributes = fields_for_export

    CSV.generate(headers: true) do |csv|
      csv << header_attributes

      non_flagged_submissions.each do |submission|
        csv << attributes.map { |attr| submission.send(attr) }
      end
    end
  end

  def user_role?(user:)
    role = user_roles.find_by_user_id(user.id)
    role.present? ? role.role : nil
  end

  # TODO: Refactor into a Report class

  # Generates 1 of 2 exported files for the A11
  # This is a one record metadata file
  def to_a11_header_csv(start_date:, end_date:)
    non_flagged_submissions = submissions.non_flagged.where('created_at >= ?', start_date).where('created_at <= ?', end_date)
    return nil if non_flagged_submissions.blank?

    header_attributes = [
      'submission comment',
      'survey_instrument_reference',
      'agency_poc_name',
      'agency_poc_email',
      'department',
      'bureau',
      'service',
      'transaction_point',
      'mode',
      'start_date',
      'end_date',
      'total_volume',
      'survey_opp_volume',
      'response_count',
      'OMB_control_number',
      'federal_register_url',
    ]

    CSV.generate(headers: true) do |csv|
      submission = non_flagged_submissions.first
      csv << header_attributes
      csv << [
        submission.form.data_submission_comment,
        submission.form.survey_instrument_reference,
        submission.form.agency_poc_name,
        submission.form.agency_poc_email,
        submission.form.department,
        submission.form.bureau,
        submission.form.service_name,
        submission.form.name,
        submission.form.medium,
        start_date,
        end_date,
        submission.form.anticipated_delivery_count,
        submission.form.survey_form_activations,
        non_flagged_submissions.length,
        submission.form.omb_approval_number,
        submission.form.federal_register_url,
      ]
    end
  end

  # Generates the 2nd of 2 exported files for the A11
  # This is a 7 record detail file; one for each question
  def to_a11_submissions_csv(start_date:, end_date:)
    non_flagged_submissions = submissions.non_flagged.where('created_at >= ?', start_date).where('created_at <= ?', end_date)
    return nil if non_flagged_submissions.blank?

    header_attributes = %w[
      standardized_question_number
      standardized_question_identifier
      customized_question_text
      likert_scale_1
      likert_scale_2
      likert_scale_3
      likert_scale_4
      likert_scale_5
      response_volume
      notes
      start_date
      end_date
    ]

    @hash = {
      answer_01: Hash.new(0),
      answer_02: Hash.new(0),
      answer_03: Hash.new(0),
      answer_04: Hash.new(0),
      answer_05: Hash.new(0),
      answer_06: Hash.new(0),
      answer_07: Hash.new(0),
    }

    # Aggregate likert scale responses
    non_flagged_submissions.each do |submission|
      @hash.each_key do |field|
        response = submission.send(field)
        @hash[field][submission.send(field)] += 1 if response.present?
      end
    end

    # TODO: Needs work
    CSV.generate(headers: true) do |csv|
      csv << header_attributes

      @hash.each_pair do |key, values|
        @question_text = '123'
        case key
        when :answer_01
          question = questions.where(answer_field: key).first
          response_volume = values.values.collect(&:to_i).sum
          @question_text = question.text
          standardized_question_number = 1
        when :answer_02
          question = questions.where(answer_field: key).first
          response_volume = values.values.collect(&:to_i).sum
          @question_text = question.text
          standardized_question_number = 2
        when :answer_03
          question = questions.where(answer_field: key).first
          response_volume = values.values.collect(&:to_i).sum
          @question_text = question.text
          standardized_question_number = 3
        when :answer_04
          question = questions.where(answer_field: key).first
          response_volume = values.values.collect(&:to_i).sum
          @question_text = question.text
          standardized_question_number = 4
        when :answer_05
          question = questions.where(answer_field: key).first
          response_volume = values.values.collect(&:to_i).sum
          @question_text = question.text
          standardized_question_number = 5
        when :answer_06
          question = questions.where(answer_field: key).first
          response_volume = values.values.collect(&:to_i).sum
          @question_text = question.text
          standardized_question_number = 6
        when :answer_07
          question = questions.where(answer_field: key).first
          response_volume = values.values.collect(&:to_i).sum
          @question_text = question.text
          standardized_question_number = 7
        end

        csv << [
          standardized_question_number,
          key,
          @question_text,
          values['1'],
          values['2'],
          values['3'],
          values['4'],
          values['5'],
          response_volume,
          '', # Empty field for the user to enter their own notes
          start_date,
          end_date,
        ]
      end
    end
  end

  def fields_for_export
    hashed_fields_for_export.keys
  end

  # TODO: Move to /models/submission.rb
  # a map of { Submission field names (to access the data) => the Header (to display) }
  def hashed_fields_for_export
    hash = {
      uuid: 'UUID',
    }

    ordered_questions.map { |q| hash[q.answer_field] = q.text }

    hash.merge!({
                  location_code: 'Location Code',
                  user_agent: 'User Agent',
                  page: 'Page',
                  referer: 'Referrer',
                  created_at: 'Created At',
                })

    if organization.enable_ip_address?
      hash.merge!({
                    ip_address: 'IP Address',
                  })
    end

    hash.merge!({
                  tag_list: 'Tags',
                })

    hash
  end

  def ordered_questions
    array = []
    form_sections.each do |section|
      array.concat(section.questions.ordered.entries)
    end
    array
  end

  def omb_number_with_expiration_date
    errors.add(:expiration_date, 'required with an OMB Number') if omb_approval_number.present? && expiration_date.blank?
    errors.add(:omb_approval_number, 'required with an Expiration Date') if expiration_date.present? && omb_approval_number.blank?
  end

  def completion_rate
    if survey_form_activations.zero?
      'N/A'
    else
      "#{((response_count / survey_form_activations.to_f) * 100).round(0)}%"
    end
  end

  def average_answer(answer)
    responses = submissions.select(answer).where("#{answer} is not null").collect(&answer)
    responses = responses.map(&:to_i)
    response_total = responses.sum

    responses_count = responses.size
    average = response_total / responses_count.to_f
    {
      response_total:,
      response_count: responses_count,
      average: average.round(2),
    }
  end
end
