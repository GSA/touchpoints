Rails.application.config.middleware.use OmniAuth::Builder do
  provider :login_dot_gov, {
    name: :login_dot_gov,
    client_id: ENV.fetch("LOGIN_GOV_CLIENT_ID"),
    idp_base_url: ENV.fetch("LOGIN_GOV_IDP_BASE_URL"),
    ial: 1,
    private_key: OpenSSL::PKey::RSA.new(ENV.fetch("LOGIN_GOV_PRIVATE_KEY")),
    redirect_uri: ENV.fetch("LOGIN_GOV_REDIRECT_URI")
  }
end
