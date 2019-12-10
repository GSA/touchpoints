class Event < ApplicationRecord

	@@names = {
		:user_deactivated => 'user_deactivated'
	}

	def self.log_event(ename, otype, oid, desc, uid = nil)
		e = self.new
		e.name = ename
		e.object_type = otype
		e.object_id = oid
		e.description = desc
		e.user_id = uid
		e.save
	end

	def self.names
		@@names
    end

    def self.valid_events
    	@@names.values
    end
end
