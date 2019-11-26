class TouchpointCache

  TOUCHPOINT_NAMESPACE = "namespace:touchpoint-"

  # Cache Store fetch will return the cached item
  # or run the block if the cached item does not exist
  def self.fetch(id)
  	Rails.cache.fetch(TOUCHPOINT_NAMESPACE + id.to_s, expires_in: 1.day) do
  		#Pull in all objects required to build a touchpoint
    	Touchpoint.includes({form: [:questions, form_sections: [questions: [:question_options]]]}, service: [:organization]).find(id)
    end
  end

  def self.invalidate(id)
  	Rails.cache.delete(TOUCHPOINT_NAMESPACE + id.to_s)
  end

end
