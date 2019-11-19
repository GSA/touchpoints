class TouchpointCache

  TOUCHPOINT_NS = "namespace:TouchPoint-"

  #Cache Store fetch will return the cached item or run the block if the cahced item does not exist
  def self.fetch(id)
  	Rails.cache.fetch(TOUCHPOINT_NS + id.to_s, expires_in: 1.day) do
  		#Pull in all objects required to build a touchpoint
    	Touchpoint.includes({form: [:questions, form_sections: [questions: [:question_options]]]}, service: [:organization]).find(id)
    end
  end

  def self.invalidate(id)
  	Rails.cache.delete(TOUCHPOINT_NS + id.to_s)
  end

end