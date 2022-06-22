# frozen_string_literal: true

class FormCache
  NAMESPACE = 'namespace:form-'

  # Cache Store fetch will return the cached item
  # or run the block if the cached item does not exist
  def self.fetch(short_uuid)
    return false if short_uuid.blank?

    Rails.cache.fetch(NAMESPACE + short_uuid.to_s, expires_in: 1.day) do
      # Pull in all objects required to build a touchpoint
      Form.includes([:questions, { form_sections: [questions: [:question_options]] }], :organization).find_by_short_uuid(short_uuid)
    end
  end

  def self.fetch_a11_analysis(short_uuid)
    return false if short_uuid.blank?

    Rails.cache.fetch("#{NAMESPACE}-a11-analysis-#{short_uuid}", expires_in: 1.day) do
      form = Form.find_by_short_uuid(short_uuid)
      report = {}
      report[:answer_01] = form.average_answer(:answer_01)
      report[:answer_02] = form.average_answer(:answer_02)
      report[:answer_03] = form.average_answer(:answer_03)
      report[:answer_04] = form.average_answer(:answer_04)
      report[:answer_05] = form.average_answer(:answer_05)
      report[:answer_06] = form.average_answer(:answer_06)
      report[:answer_07] = form.average_answer(:answer_07)
      report
    end
  end

  def self.fetch_performance_gov_analysis(short_uuid)
    return false if short_uuid.blank?

    Rails.cache.fetch("#{NAMESPACE}-performance-gov-analysis-#{short_uuid}", expires_in: 1.day) do
      form = Form.find_by_short_uuid(short_uuid)
      report = {}
      report[:quarterly_submissions] = form.submissions.order(:created_at).entries.map { |e| e.attributes.merge(quarter: e.created_at.beginning_of_quarter.to_date, end_of_quarter: e.created_at.end_of_quarter) }
      report[:quarters] = report[:quarterly_submissions].pluck(:quarter).uniq
      report
    end
  end

  def self.invalidate(short_uuid)
    Rails.cache.delete(NAMESPACE + short_uuid.to_s)
  end

  def self.invalidate_reports(short_uuid)
    Rails.cache.delete("#{NAMESPACE}-performance-gov-analysis-#{short_uuid}")
    Rails.cache.delete("#{NAMESPACE}-a11-analysis-#{short_uuid}")
  end
end
