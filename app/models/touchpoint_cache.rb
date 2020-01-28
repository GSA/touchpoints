class TouchpointCache

  TOUCHPOINT_NAMESPACE = "namespace:touchpoint-"

  # Cache Store fetch will return the cached item
  # or run the block if the cached item does not exist
  def self.fetch(short_uuid)
    return false unless short_uuid.present?

    Rails.cache.fetch(TOUCHPOINT_NAMESPACE + short_uuid.to_s, expires_in: 1.day) do
      # Pull in all objects required to build a touchpoint
      Touchpoint.includes({ form: [:questions, form_sections: [questions: [:question_options]]] }, :organization).find_by_short_uuid(short_uuid)
    end
  end

  def self.invalidate(short_uuid)
    Rails.cache.delete(TOUCHPOINT_NAMESPACE + short_uuid.to_s)
  end

end
