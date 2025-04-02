class SubmissionSpamPreventionMechanism < ActiveRecord::Migration[8.0]
  def change
    add_column :submissions, :spam_prevention_mechanism, :string, default: "", comment: "Specify which spam prevention mechanism was used, if any."
  end
end
