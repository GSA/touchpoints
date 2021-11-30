class FormCache

  NAMESPACE = "namespace:form-"

  # Cache Store fetch will return the cached item
  # or run the block if the cached item does not exist
  def self.fetch(short_uuid)
    return false unless short_uuid.present?

    Rails.cache.fetch(NAMESPACE + short_uuid.to_s, expires_in: 1.day) do
      # Pull in all objects required to build a touchpoint
      Form.includes([:questions, form_sections: [questions: [:question_options]]], :organization).find_by_short_uuid(short_uuid)
    end
  end

  def self.fetch_all_analysis(short_uuid)
    return false unless short_uuid.present?

    Rails.cache.fetch(NAMESPACE + '-a11-analysis-' + short_uuid.to_s, expires_in: 1.day) do
      Rails.logger.debug("Adding a11 analysis to cache at #{Time.now}")
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

  def self.invalidate(short_uuid)
    Rails.cache.delete(NAMESPACE + short_uuid.to_s)
  end

end
