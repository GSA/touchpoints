# frozen_string_literal: true

require 'csv'

class Version
  def	self.to_csv(model)
    users = User.all
    user_email_map = {}
    users.map { |user| user_email_map[user.id] = user.email }
    CSV.generate(headers: true) do |csv|
      csv << ['Event', 'Created At', 'Whodunnit Id', 'Whodunnit Email', 'Changeset', 'Object state']

      model.versions.reverse.each do |version|
        csv << [version.event, version.created_at, version.whodunnit, user_email_map[version.whodunnit.to_i], version.changeset, version.object]
      end
    end
  end
end
