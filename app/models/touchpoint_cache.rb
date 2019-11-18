class TouchpointCache

  @@tp_mem = {}

  def self.retrieve_tp(id)
  	#Pull in all objects required to build a touchpoint
    @@tp_mem[id] = Touchpoint.includes({form: [:questions, form_sections: [:questions]]}, :service).find(id) unless @@tp_mem[id]
  	@@tp_mem[id]
  end

end