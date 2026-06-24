if defined?(Rswag::Ui)
  Rswag::Ui.configure do |c|

    # List the OpenAPI endpoints that you want to be documented through the
    # swagger-ui. The first parameter is the path (absolute or relative to the UI
    # host) to the corresponding endpoint and the second is a title that will be
    # displayed in the document selector.

    c.openapi_endpoint '/api/v1/openapi.yml', 'API V1 Docs'

    # Add Basic Auth in case your API is private
    # c.basic_auth_enabled = true
    # c.basic_auth_credentials 'username', 'password'
  end
end