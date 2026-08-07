# frozen_string_literal: true

# View helpers for presenting spam-check results in the admin interface.
#
# The human-readable copy lives with each check in app/services/spam_checks/;
# these helpers just look up the check by its stored reason identifier (as
# found in submission.spam_determination["reasons"]).
module SpamHelper
  def spam_reason_label(reason)
    check = SpamChecks::Base.for(reason)
    check ? check.label : reason.to_s.humanize
  end

  def spam_reason_description(reason, context = {})
    SpamChecks::Base.for(reason)&.description(context || {})
  end
end
