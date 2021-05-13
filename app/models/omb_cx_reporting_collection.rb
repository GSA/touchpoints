class OmbCxReportingCollection < ApplicationRecord
  belongs_to :collection

  validates :service_provided, presence: true
end
