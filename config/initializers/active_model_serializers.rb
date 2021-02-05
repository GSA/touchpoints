ActiveModelSerializers.config.adapter = :json_api
ActiveModelSerializers.config.key_transform = :unaltered
ActiveSupport.on_load(:action_controller) do
  require 'active_model_serializers/register_jsonapi_renderer'
end
