class ScheduledTask

	def self.check_expiring_touchpoints
		tps = Touchpoint.where(expiration_date: Date.today + 7).or(Touchpoint.where(expiration_date: ScheduledTask.skip_weekends(Date.today)))
		tps.each do | tp |
			UserMailer.touchpoint_expiring_notification(tp).deliver_later
		end
	end

	def self.skip_weekends(date, inc = 1)
	  date += inc
	  while date.wday == 0 || date.wday == 6
	    date += inc
	  end
	  date
	end

end