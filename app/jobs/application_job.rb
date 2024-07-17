# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include S3Helper
end
