# frozen_string_literal: true

Aws::Rails.add_action_mailer_delivery_method(:ses,
                                             access_key_id: ENV.fetch('AWS_SES_ACCESS_KEY_ID', nil),
                                             secret_access_key: ENV.fetch('AWS_SES_SECRET_ACCESS_KEY', nil),
                                             region: ENV.fetch('AWS_SES_REGION', nil))
