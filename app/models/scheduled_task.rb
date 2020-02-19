class ScheduledTask

	def self.check_expiring_forms
		forms = Form.where(expiration_date: Date.today + 7).or(Form.where(expiration_date: ScheduledTask.skip_weekends(Date.today)))
		forms.each do |f|
			UserMailer.form_expiring_notification(f).deliver_later
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
