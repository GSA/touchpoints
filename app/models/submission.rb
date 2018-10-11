class Submission < ApplicationRecord
  belongs_to :touchpoint

  validates :first_name, presence: true, if: :validate_first_name?
  validates :body, presence: true, if: :validate_body?

  # NOTE: this is brittle.
  #       this pattern will require every field to declare its validations
  #       Rethink.
  def validate_first_name?
    self.touchpoint.form.kind == "recruiter"
  end

  def validate_body?
    self.touchpoint.form.kind == "open-ended"
  end
end
