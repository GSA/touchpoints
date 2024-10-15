# frozen_string_literal: true

require 'csv'

class Form < ApplicationRecord
  include AASM

  belongs_to :organization
  belongs_to :service, optional: true

  has_many :form_sections, dependent: :delete_all
  has_many :questions, dependent: :destroy, counter_cache: :questions_count
  has_many :submissions

  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles, primary_key: :form_id

  acts_as_taggable_on :tags

  validates :name, presence: true
  validates :disclaimer_text, length: { in: 0..1000, allow_blank: true }
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

  def self.filtered_forms(user, aasm_state)
    if user.admin?
      items = all
    elsif user.organizational_form_approver?
      items = user.organization.forms
    else
      items = user.forms.order('organization_id ASC').order('name ASC')
    end

    items = items.non_templates
    items = items.where(aasm_state: aasm_state) if aasm_state.present? && aasm_state != "all"
    items
  end

  def target_for_delivery_method
    errors.add(:element_selector, "can't be blank for an inline form") if (delivery_method == 'custom-button-modal' || delivery_method == 'inline') && (element_selector == '')
  end

  def roles
    user_roles.map { |role| { role: role.role, user: role.user }}
  end

  def form_managers
    roles.select { |role| role[:role] == 'form_manager' }.map { |r| r[:user] }
  end

  def response_viewers
    roles.select { |role| role[:role] == 'response_viewer' }.map { |r| r[:user]}
  end

  def ensure_modal_text
    errors.add(:modal_button_text, "can't be blank for an modal form") if delivery_method == 'modal' && modal_button_text.empty?
  end

  def ensure_no_responses
    if response_count.positive?
      errors.add(:response_count_error, 'This form cannot be deleted because it has responses')
      throw(:abort)
    end
  end

  def load_uswds
    load_css && delivery_method != 'touchpoints-hosted-only'
  end

  def prefix(css_class_name)
    load_uswds ? "fba-#{css_class_name}" : css_class_name
  end

  after_commit do |form|
    FormCache.invalidate(form.short_uuid)
  end

  DELIVERY_METHODS = [
    ['touchpoints-hosted-only', 'Hosted on Touchpoints'],
    ['modal', 'Blue button & modal on your website'],
    ['custom-button-modal', 'Custom button & modal on your website'],
    ['inline', 'Embedded inline on your website'],
  ].freeze

  # don't show the form submit button when yes_no_buttons are present
  # or when there is only 1 custom_text_display
  def suppress_submit_button
    questions.collect(&:question_type).include?('yes_no_buttons') ||
      (questions.size == 1 && questions.collect(&:question_type).include?('custom_text_display'))
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

  # used to initially set tags (or reset them, if necessary)
  def set_submission_tags!
    submission_tags = submissions.collect(&:tags).uniq.sort_by { |i| i.name }
    self.update!(submission_tags: submission_tags)
  end

  # called when a tag is added to a submission
  def update_submission_tags!(tag_list)
    submission_tags = (self.submission_tags + tag_list).uniq.compact.sort
    self.update!(submission_tags: submission_tags)
  end

  # lazily called from a view when a tag is used to search, but returns 0 results
  def remove_submission_tag!(tag)
    self.update!(submission_tags: submission_tags - [tag])
  end

  aasm do
    state :created, initial: true
    state :submitted
    state :approved
    state :published # manual
    state :archived # after End Date, or manual

    event :submit do
      transitions from: %i[created],
        to: :submitted,
        guard: :organization_has_form_approval_enabled?,
        after: :set_submitted_at
    end
    event :approve do
      transitions from: %i[submitted],
        to: :approved,
        guard: :organization_has_form_approval_enabled?,
        after: :set_approved_at
    end
    event :publish do
      transitions from: %i[created approved], to: :published
    end
    event :archive do
      transitions from: %i[created published], to: :archived,
                  after: :set_archived_at
    end
    event :reset do
      transitions to: :created
    end
  end

  def transitionable_states
    aasm.states(permitted: true)
  end

  def all_states
    aasm.states
  end

  def events
    Event.where(object_type: 'Form', object_uuid: self.uuid).order(:created_at)
  end

  def duplicate!(new_user:)
    new_form = dup
    new_form.name = "Copy of #{name}"
    new_form.title = new_form.name
    new_form.survey_form_activations = 0
    new_form.response_count = 0
    new_form.questions_count = 0
    new_form.last_response_created_at = nil
    new_form.aasm_state = :created
    new_form.uuid = nil
    new_form.legacy_touchpoint_id = nil
    new_form.legacy_touchpoint_uuid = nil
    new_form.template = false
    new_form.organization = new_user.organization
    new_form.legacy_form_embed = false
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
      @event = Event.log_event(Event.names[:form_archived], 'Form', form.uuid, "Form #{form.name} archived at #{DateTime.now}", 1)
      form.archive!
      UserMailer.form_status_changed(form:, action: 'archived', event: @event).deliver_later
    end
  end

  def set_uuid
    self.uuid = SecureRandom.uuid if uuid.blank?
  end

  def self.send_inactive_form_emails_since(days_ago)
    inactive_published_forms = find_inactive_forms_since(days_ago)

    inactive_published_forms.each do |form|
      user_emails = form.form_managers.reject { |user| user.inactive }.collect(&:email)
      UserMailer.form_inactivity_email(form_short_uuid: form.short_uuid, user_emails: user_emails, days_ago: days_ago).deliver_later
      puts "sending for #{form.short_uuid} to #{user_emails}"
    end
  end

  def self.find_inactive_forms_since(days_ago)
    min_time = Time.now - days_ago.days
    max_time = Time.now - (days_ago - 1).days
    Form.published.where("last_response_created_at BETWEEN ? AND ?", min_time, max_time)
  end

  def deployable_form?
    published?
  end

  # returns javascript text that can be used standalone
  # or injected into a GTM Container Tag
  def touchpoints_js_string
    if self.legacy_form_embed
      ApplicationController.new.render_to_string(partial: 'components/widget/fba', formats: :js, locals: { touchpoint: self })
    else
      ApplicationController.new.render_to_string(partial: 'components/widget/fba2', formats: :js, locals: { touchpoint: self })
    end
  end

  def non_flagged_submissions(start_date: nil, end_date: nil)
    submissions
      .non_flagged
      .where(created_at: start_date..)
      .where(created_at: ..end_date)
  end

  def to_csv(start_date: nil, end_date: nil)
    non_flagged_submissions = non_flagged_submissions(start_date:, end_date:)
      .order('created_at')
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

  def to_combined_a11_v2_csv(start_date: nil, end_date: nil)
    non_flagged_submissions = non_flagged_submissions(start_date:, end_date:)
      .order('created_at')
    return nil if non_flagged_submissions.blank?

    header_attributes = hashed_fields_for_export.values
    attributes = fields_for_export

    header_attributes = hashed_fields_for_export.values
    a11_v2_header_attributes = [
      :external_id,
      :question_1,
      :positive_effectiveness,
      :positive_ease,
      :positive_efficiency,
      :positive_transparency,
      :positive_humanity,
      :positive_employee,
      :positive_other,
      :negative_effectiveness,
      :negative_ease,
      :negative_efficiency,
      :negative_transparency,
      :negative_humanity,
      :negative_employee,
      :negative_other,
      :question_4
    ]

    attributes = fields_for_export

    answer_02_options = self.questions.where(answer_field: "answer_02").first.question_options.collect(&:value)
    answer_03_options = self.questions.where(answer_field: "answer_03").first.question_options.collect(&:value)

    CSV.generate(headers: true) do |csv|
      csv << header_attributes + a11_v2_header_attributes

      non_flagged_submissions.each do |submission|
        csv << attributes.map { |attr| submission.send(attr) } + [
          submission.id,
          submission.answer_01,
          submission.answer_02 && submission.answer_02.split(",").include?("effectiveness") ? 1 :(answer_02_options.include?("effectiveness") ? 0 : 'null'),
          submission.answer_02 && submission.answer_02.split(",").include?("ease") ? 1 : (answer_02_options.include?("ease") ? 0 : 'null'),
          submission.answer_02 && submission.answer_02.split(",").include?("efficiency") ? 1 : (answer_02_options.include?("efficiency") ? 0 : 'null'),
          submission.answer_02 && submission.answer_02.split(",").include?("transparency") ? 1 : (answer_02_options.include?("transparency") ? 0 : 'null'),
          submission.answer_02 && submission.answer_02.split(",").include?("humanity") ? 1 : (answer_02_options.include?("humanity") ? 0 : 'null'),
          submission.answer_02 && submission.answer_02.split(",").include?("employee") ? 1 : (answer_02_options.include?("employee") ? 0 : 'null'),
          submission.answer_02 && submission.answer_02.split(",").include?("other") ? 1 : (answer_02_options.include?("other") ? 0 : 'null'),

          submission.answer_03 && submission.answer_03.split(",").include?("effectiveness") ? 1 : (answer_03_options.include?("effectiveness") ? 0 : 'null'),
          submission.answer_03 && submission.answer_03.split(",").include?("ease") ? 1 : (answer_03_options.include?("ease") ? 0 : 'null'),
          submission.answer_03 && submission.answer_03.split(",").include?("efficiency") ? 1 : (answer_03_options.include?("efficiency") ? 0 : 'null'),
          submission.answer_03 && submission.answer_03.split(",").include?("transparency") ? 1 : (answer_03_options.include?("transparency") ? 0 : 'null'),
          submission.answer_03 && submission.answer_03.split(",").include?("humanity") ? 1 : (answer_03_options.include?("humanity") ? 0 : 'null'),
          submission.answer_03 && submission.answer_03.split(",").include?("employee") ? 1 : (answer_03_options.include?("employee") ? 0 : 'null'),
          submission.answer_03 && submission.answer_03.split(",").include?("other") ? 1 : (answer_03_options.include?("other") ? 0 : 'null'),

          submission.answer_04
        ]
      end
    end
  end

  def to_a11_v2_csv(start_date: nil, end_date: nil)
    non_flagged_submissions = submissions
      .non_flagged
      .where('created_at >= ?', start_date)
      .where('created_at <= ?', end_date)
      .order('created_at')
    return nil if non_flagged_submissions.blank?

    header_attributes = hashed_fields_for_export.values
    header_attributes = [
      :external_id,
      :question_1,
      :positive_effectiveness,
      :positive_ease,
      :positive_efficiency,
      :positive_transparency,
      :positive_humanity,
      :positive_employee,
      :positive_other,
      :negative_effectiveness,
      :negative_ease,
      :negative_efficiency,
      :negative_transparency,
      :negative_humanity,
      :negative_employee,
      :negative_other,
      :question_4
    ]

    attributes = fields_for_export

    answer_02_options = self.questions.where(answer_field: "answer_02").first.question_options.collect(&:value)
    answer_03_options = self.questions.where(answer_field: "answer_03").first.question_options.collect(&:value)

    CSV.generate(headers: true) do |csv|
      csv << header_attributes

      non_flagged_submissions.each do |submission|
        csv << [
          submission.id,
          submission.answer_01,
          submission.answer_02 && submission.answer_02.split(",").include?("effectiveness") ? 1 :(answer_02_options.include?("effectiveness") ? 0 : 'null'),
          submission.answer_02 && submission.answer_02.split(",").include?("ease") ? 1 : (answer_02_options.include?("ease") ? 0 : 'null'),
          submission.answer_02 && submission.answer_02.split(",").include?("efficiency") ? 1 : (answer_02_options.include?("efficiency") ? 0 : 'null'),
          submission.answer_02 && submission.answer_02.split(",").include?("transparency") ? 1 : (answer_02_options.include?("transparency") ? 0 : 'null'),
          submission.answer_02 && submission.answer_02.split(",").include?("humanity") ? 1 : (answer_02_options.include?("humanity") ? 0 : 'null'),
          submission.answer_02 && submission.answer_02.split(",").include?("employee") ? 1 : (answer_02_options.include?("employee") ? 0 : 'null'),
          submission.answer_02 && submission.answer_02.split(",").include?("other") ? 1 : (answer_02_options.include?("other") ? 0 : 'null'),

          submission.answer_03 && submission.answer_03.split(",").include?("effectiveness") ? 1 : (answer_03_options.include?("effectiveness") ? 0 : 'null'),
          submission.answer_03 && submission.answer_03.split(",").include?("ease") ? 1 : (answer_03_options.include?("ease") ? 0 : 'null'),
          submission.answer_03 && submission.answer_03.split(",").include?("efficiency") ? 1 : (answer_03_options.include?("efficiency") ? 0 : 'null'),
          submission.answer_03 && submission.answer_03.split(",").include?("transparency") ? 1 : (answer_03_options.include?("transparency") ? 0 : 'null'),
          submission.answer_03 && submission.answer_03.split(",").include?("humanity") ? 1 : (answer_03_options.include?("humanity") ? 0 : 'null'),
          submission.answer_03 && submission.answer_03.split(",").include?("employee") ? 1 : (answer_03_options.include?("employee") ? 0 : 'null'),
          submission.answer_03 && submission.answer_03.split(",").include?("other") ? 1 : (answer_03_options.include?("other") ? 0 : 'null'),

          submission.answer_04
        ]
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
          next unless question.present?
          response_volume = values.values.collect(&:to_i).sum
          @question_text = question.text
          standardized_question_number = 6
        when :answer_07
          question = questions.where(answer_field: key).first
          next unless question.present?
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
  # a hash/map of Submission field names and CSV Header text
  # { field_name: 'Header Text' }
  def hashed_fields_for_export
    ordered_hash = ActiveSupport::OrderedHash.new
    ordered_hash.merge!({
      id: 'ID',
      uuid: 'UUID',
    })

    ordered_questions.map { |q| ordered_hash[q.answer_field] = q.text }

    ordered_hash.merge!({
      location_code: 'Location Code',
      user_agent: 'User Agent',
      aasm_state: 'Status',
      archived: 'Archived',
      flagged: 'Flagged',
      page: 'Page',
      hostname: 'Hostname',
      referer: 'Referrer',
      created_at: 'Created At',
    })

    if organization.enable_ip_address?
      ordered_hash.merge!({
        ip_address: 'IP Address',
      })
    end

    ordered_hash.merge!({
      tags: 'Tags',
    })

    ordered_hash
  end

  def ordered_questions
    array = []
    form_sections.each do |section|
      array.concat(section.questions.entries)
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

  def organization_has_form_approval_enabled?
    organization.form_approval_enabled
  end

  # use this validator to provide soft UI guidance, rather than strong model validation
  def ensure_a11_v2_format
    # ensure `answer_01` is a big thumbs question
    question_1 = self.ordered_questions.find { |q| q.answer_field == "answer_01" }
    if question_1.question_type != 'big_thumbs_up_down_buttons'
      errors.add(:base, "The question for `answer_01` must be a \"Big Thumbs Up/Down\" component")
    end

    # ensure the form has the 4 required questions
    required_elements = ["answer_01", "answer_02", "answer_03", "answer_04"]
    unless contains_elements?(questions.collect(&:answer_field), required_elements)
      errors.add(:base, "The A-11 v2 form must have questions for #{required_elements.to_sentence}")
    end

    # ensure the positive indicators include ease and effectiveness
    question_2 = self.ordered_questions.find { |q| q.answer_field == "answer_02" }
    question_options = question_2.question_options

    question_option_values = question_options.collect(&:value)
    required_options = ["effectiveness", "ease"]
    missing_options = required_options - question_option_values
    if missing_options.any?
      errors.add(:base, "The question options for Question 2 must include: #{missing_options.join(', ')}")
    end

    # ensure the positive indicators include ease and effectiveness
    question_3 = self.ordered_questions.find { |q| q.answer_field == "answer_03" }
    question_options = question_3.question_options

    question_option_values = question_options.collect(&:value)
    required_options = ["effectiveness", "ease"]
    missing_options = required_options - question_option_values
    if missing_options.any?
      errors.add(:base, "The question options for Question 3 must include: #{missing_options.join(', ')}")
    end
  end

  def warn_about_not_too_many_questions
    if questions.size > 12
      errors.add(:base, "Touchpoints supports a maximum of 20 questions. There are currently #{questions_count} questions. Fewer questions tend to yield higher response rates.")
    end
  end

  def contains_elements?(array, required_elements)
    (required_elements & array).length == required_elements.length
  end

  def self.forms_whose_retention_period_has_passed
    cutoff_year = FiscalYear.last_fiscal_year - 3
    cutoff_date = FiscalYear.last_day_of_fiscal_quarter(cutoff_year, 4)
    Form.where("aasm_state = 'archived'")
        .where("archived_at < ?", cutoff_date)
  end

  private

  def set_submitted_at
    self.update(submitted_at: Time.current)
  end

  def set_approved_at
    self.update(approved_at: Time.current)
  end

  def set_archived_at
    self.update(archived_at: Time.current)
  end
end
