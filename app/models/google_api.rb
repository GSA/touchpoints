class GoogleApi
  require 'google/apis'
  require 'google/apis/tagmanager_v2'

  attr_reader :service

  def self.gtm_header_text(key:)
<<-eos
<!-- Google Tag Manager -->
<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','#{key}');</script>
<!-- End Google Tag Manager -->
eos
  end

  def self.gtm_body_text(key:)
<<-eos
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=#{key}"
height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->
eos
  end

  def self.config_io
    if ENV["GOOGLE_CONFIG"].present?
      StringIO.new(ENV.fetch("GOOGLE_CONFIG"))
    else
      File.open("tmp/google_service_account_#{Rails.env.downcase}.json")
    end
  end

  def initialize
    Google::Apis.logger.level = Logger::DEBUG if Rails.env.development?

    scope = [
      Google::Apis::TagmanagerV2::AUTH_TAGMANAGER_MANAGE_ACCOUNTS,
      Google::Apis::TagmanagerV2::AUTH_TAGMANAGER_READONLY,
      Google::Apis::TagmanagerV2::AUTH_TAGMANAGER_MANAGE_USERS,
      Google::Apis::TagmanagerV2::AUTH_TAGMANAGER_PUBLISH,
      Google::Apis::TagmanagerV2::AUTH_TAGMANAGER_EDIT_CONTAINERS,
      Google::Apis::TagmanagerV2::AUTH_TAGMANAGER_EDIT_CONTAINERVERSIONS,
      Google::Apis::TagmanagerV2::AUTH_TAGMANAGER_DELETE_CONTAINERS
    ].freeze

    authorizer = Google::Auth::ServiceAccountCredentials.make_creds({
      json_key_io: GoogleApi.config_io,
      scope: scope
    })
    authorizer.fetch_access_token!

    @service = Google::Apis::TagmanagerV2::TagManagerService.new
    @service.authorization = authorizer
    @account_id = ENV.fetch("GOOGLE_TAG_MANAGER_ACCOUNT_ID")
  end

  def get_accounts
    @service.list_accounts.account # => []
  end

  def get_account(account_id:)
    @service.get_account("accounts/#{account_id}")
  end

  def list_account_containers(account_id:)
    @service.list_account_containers("accounts/#{account_id}").container
  end

  def list_account_container_workspaces(path:)
    @service.list_account_container_workspaces(path).workspace
  end

  def list_account_user_permissions(account_id:)
    @service.list_account_user_permissions("accounts/#{account_id}").user_permission
  end

  def clean_account_containers(account_id:)
    return if Rails.env.production?

    containers  = list_account_containers(account_id: account_id)
    containers.each do |c|
      begin
        @service.delete_account_container(c.path)
      rescue
        puts "WARNING: Could not delete GTM Container #{c.name} - #{c.fingerprint}"
      end
    end
  end

  # Reference: https://github.com/googleapis/google-api-ruby-client/blob/711dfb83b33c03535076917726956584d5c8bf9a/generated/google/apis/tagmanager_v2/representations.rb
  def create_account_container(name:)
    # Define the new Container
    new_container = Google::Apis::TagmanagerV2::Container.new
    new_container.name = name
    new_container.usage_context = ["web"]

    # Post it to GTM's API
    @service.create_account_container("accounts/#{ENV.fetch('GOOGLE_TAG_MANAGER_ACCOUNT_ID')}", new_container)
  end

  def path_helper(account_id:, container_id:)
    "accounts/#{account_id}/containers/#{container_id}"
  end

  def get_account_container(path:)
    @service.get_account_container(path)
  end

  # NOTE: This is an operation on a Container.
  def create_container_custom_configs(path:)
    create_trigger_js_error(path: path)
    create_trigger_frustrated_user(path: path)
    create_variable_auto_event_var_element(path: path)
    create_variable_auto_event_var_element_id(path: path)
    create_variable_auto_event_var_element_text(path: path)
    create_variable_element_text(path: path)
    create_variable_ga_property_id(path: path)
    create_variable_user_agent(path: path)
    create_variable_web_app_url(path: path)
    create_variable_client_id(path: path)
    create_trigger_homepage_only(path: path)
    create_trigger_recruiter_submit(path: path)
  end

  def create_touchpoints_tag(path:, body:)
    triggers = list_account_container_workspace_triggers(path: path).trigger
    homepage_only_trigger = triggers.select { |trigger| trigger.name == "Homepage only" }.first
    raise ArgumentException unless homepage_only_trigger
    homepage_only_trigger_id = homepage_only_trigger.trigger_id
    create_touchpoints_js_tag(path: path, body: body, trigger_id: homepage_only_trigger_id)
  end

  # Define Variables
  def create_variable_auto_event_var_element(path:)
    new_variable = Google::Apis::TagmanagerV2::Variable.new

    new_variable.name = "Auto-Event Var - Element"
    new_variable.type = "aev"
    new_variable.parameter = [
      {
        "type": "BOOLEAN",
        "key": "setDefaultValue",
        "value": "false"
      },
      {
        "type": "TEMPLATE",
        "key": "varType",
        "value": "ELEMENT"
      }
    ]
    @service.create_account_container_workspace_variable(path, new_variable)
  end

  def create_variable_auto_event_var_element_id(path:)
    new_variable = Google::Apis::TagmanagerV2::Variable.new

    new_variable.name = "Auto-Event Var - Element Id"
    new_variable.type = "aev"
    new_variable.parameter = [
      {
        "type": "BOOLEAN",
        "key": "setDefaultValue",
        "value": "false"
      },
      {
        "type": "TEMPLATE",
        "key": "varType",
        "value": "ID"
      }
    ]
    @service.create_account_container_workspace_variable(path, new_variable)
  end

  def create_variable_auto_event_var_element_text(path:)
    new_variable = Google::Apis::TagmanagerV2::Variable.new

    new_variable.name = "Auto-Event Var - Element Text"
    new_variable.type = "aev"
    new_variable.parameter = [
      {
        "type": "BOOLEAN",
        "key": "setDefaultValue",
        "value": "false"
      },
      {
        "type": "TEMPLATE",
        "key": "varType",
        "value": "TEXT"
      }
    ]
    @service.create_account_container_workspace_variable(path, new_variable)
  end

  def create_variable_element_text(path:)
    new_variable = Google::Apis::TagmanagerV2::Variable.new

    new_variable.name = "Element Text"
    new_variable.type = "d"
    new_variable.parameter = [
      {
        "type": "TEMPLATE",
        "key": "elementId",
        "value": "{{Auto-Event Var - Element Id}}"
      },
      {
        "type": "TEMPLATE",
        "key": "selectorType",
        "value": "ID"
      }
    ]
    @service.create_account_container_workspace_variable(path, new_variable)
  end

  def create_variable_ga_property_id(path:)
    new_variable = Google::Apis::TagmanagerV2::Variable.new

    new_variable.name = "GA Property ID"
    new_variable.type = "c"
    new_variable.parameter = [
        {
          "type": "TEMPLATE",
          "key": "value",
          "value": "UA-93344103-1"
        }
      ]
      @service.create_account_container_workspace_variable(path, new_variable)
  end

  def create_variable_recruiter_email(path:)
    new_variable = Google::Apis::TagmanagerV2::Variable.new

    new_variable.name = "Recruiter-Email"
    new_variable.type = "jsm"
    new_variable.parameter = [
      {
        "type": "TEMPLATE",
        "key": "javascript",
        "value": "function() {\n  var inputField = document.getElementsByClassName(\"email-address\")[0];\n  return inputField.value || \"\";\n}"
      }
    ]
    @service.create_account_container_workspace_variable(path, new_variable)
  end

  def create_variable_recruiter_name(path:)
    new_variable = Google::Apis::TagmanagerV2::Variable.new

    new_variable.name = "Recruiter-Name"
    new_variable.type = "jsm"
    new_variable.parameter = [
      {
        "type": "TEMPLATE",
        "key": "javascript",
        "value": "function() {\n  var inputField = document.getElementsByClassName(\"full-name\")[0];\n  return inputField.value || \"\";\n}\n"
      }
    ]
    @service.create_account_container_workspace_variable(path, new_variable)
  end

  def create_variable_recruiter_timestamp(path:)
    new_variable = Google::Apis::TagmanagerV2::Variable.new

    new_variable.name = "Recruiter-Timestamp"
    new_variable.type = "jsm"
    new_variable.parameter = [
      {
        "type": "TEMPLATE",
        "key": "javascript",
        "value": "function(){\n  var today = new Date();\n  var str = today.toUTCString();\n  return str;\n}"
      }
    ]
    @service.create_account_container_workspace_variable(path, new_variable)
  end

  def create_variable_user_agent(path:)
    new_variable = Google::Apis::TagmanagerV2::Variable.new

    new_variable.name = "UserAgent"
    new_variable.type = "j"
    new_variable.parameter = [
      {
        "type": "TEMPLATE",
        "key": "name",
        "value": "navigator.userAgent"
      }
    ]
    @service.create_account_container_workspace_variable(path, new_variable)
  end

  def create_variable_web_app_url(path:)
    new_variable = Google::Apis::TagmanagerV2::Variable.new

    new_variable.name = "WebAppURL"
    new_variable.type = "c"
    new_variable.parameter = [
      {
        "type": "TEMPLATE",
        "key": "value",
        "value": "https://script.google.com/a/macros/gsa.gov/s/AKfycbwRDwJ2V3Ui-JNsA0SUb_mekFdM4yTTuPassT740YIxtJOoUOXj/exec"
      }
    ]
    @service.create_account_container_workspace_variable(path, new_variable)
  end

  def create_variable_client_id(path:)
    new_variable = Google::Apis::TagmanagerV2::Variable.new

    new_variable.name = "clientId"
    new_variable.type = "jsm"
    new_variable.parameter = [
      {
        "type": "TEMPLATE",
        "key": "javascript",
        "value": "function() {\n  try {\n    var trackers = ga.getAll();\n    var i, len;\n    for (i = 0, len = trackers.length; i < len; i += 1) {\n      if (trackers[i].get('trackingId') === {{GA Property ID}}) {\n        return trackers[i].get('clientId');\n      }\n    }\n  } catch(e) {}  \n  return 'false';\n}"
      }
    ]
    @service.create_account_container_workspace_variable(path, new_variable)
  end

  # Define Triggers
  def create_trigger_js_error(path:)
    new_trigger = Google::Apis::TagmanagerV2::Trigger.new

    new_trigger.name = "JS Error"
    new_trigger.type = "JS_ERROR"
    @service.create_account_container_workspace_trigger(path, new_trigger)
  end

  def create_trigger_frustrated_user(path:)
    new_trigger = Google::Apis::TagmanagerV2::Trigger.new

    new_trigger.name = "Frustrated User"
    new_trigger.type = "CUSTOM_EVENT"
    new_trigger.custom_event_filter = [{
      "type": "EQUALS",
      "parameter": [{
          "type": "TEMPLATE",
          "key": "arg0",
          "value": "{{_event}}"
        },
        {
          "type": "TEMPLATE",
          "key": "arg1",
          "value": "frustratedEvent"
        }
      ]
    }]
    @service.create_account_container_workspace_trigger(path, new_trigger)
  end

  def create_trigger_homepage_only(path:)
    new_trigger = Google::Apis::TagmanagerV2::Trigger.new

    new_trigger.name = "Homepage only"
    new_trigger.type = "PAGEVIEW"
    new_trigger.filter = [{
      "type": "MATCH_REGEX",
      "parameter": [{
          "type": "TEMPLATE",
          "key": "arg0",
          "value": "{{Page URL}}"
        },
        {
          "type": "TEMPLATE",
          "key": "arg1",
          "value": "(https://touchpoints-staging.app.cloud.gov/|localhost:3000)"
        }
      ]
    }]
    @service.create_account_container_workspace_trigger(path, new_trigger)
  end

  def create_trigger_recruiter_submit(path:)
    new_trigger = Google::Apis::TagmanagerV2::Trigger.new

    new_trigger.name = "Recruiter-Submit"
    new_trigger.type = "CLICK"
    new_trigger.filter = [{
      "type": "EQUALS",
      "parameter": [{
          "type": "TEMPLATE",
          "key": "arg0",
          "value": "{{Click ID}}"
        },
        {
          "type": "TEMPLATE",
          "key": "arg1",
          "value": "gaf-submit"
        }
      ]
    }]
    @service.create_account_container_workspace_trigger(path, new_trigger)
  end
  # End Define Triggers

  def create_touchpoints_js_tag(path:, body:, trigger_id:)
    new_tag = Google::Apis::TagmanagerV2::Tag.new
    new_tag.name = "touchpoints.js #{rand(10000)}"
    new_tag.type = "html"
    new_tag.firing_trigger_id = [trigger_id]
    new_tag.parameter = [{
      "key": "html",
      "type": "template",
      "value": "<script>#{body}</script>"
    }]

    # Create Tag via GTM's API
    @service.create_account_container_workspace_tag(path, new_tag)
  end

  def create_recruiter_to_google_sheet_tag(path:)
    new_tag = Google::Apis::TagmanagerV2::Tag.new
    new_tag.name = "Recruiter to Google Sheet"
    new_tag.type = "img"
    new_tag.parameter = [
      {
        "type": "BOOLEAN",
        "key": "useCacheBuster",
        "value": "true"
      },
      {
        "type": "TEMPLATE",
        "key": "url",
        "value": "{{WebAppURL}}?Name={{Recruiter-Name}}&Email={{Recruiter-Email}}&UserAgent={{UserAgent}}&Date={{Recruiter-Timestamp}}&Referrer={{Referrer}}&URL={{Page URL}}"
      },
      {
        "type": "TEMPLATE",
        "key": "cacheBusterQueryParam",
        "value": "gtmcb"
      }
    ]

    # Create Tag via GTM's API
    @service.create_account_container_workspace_tag(path, new_tag)
  end

  def create_account_container_workspace_version(path:)
    @service.create_account_container_workspace_version(path)
  end

  def create_account_container_workspace_trigger(path:, trigger:)
    @service.create_account_container_workspace_trigger(path, trigger)
  end

  def publish_account_container_version(path:)
    @service.publish_account_container_version(path)
  end

  def get_account_container_version(path:)
    @service.get_account_container_version(path)
  end

  def live_account_container_version(path:)
    @service.live_account_container_version(path)
  end

  def create_account_container_workspace_variable(path:)
    @service.create_account_container_workspace_variable(path)
  end

  def set_account_container_version_latest(path:)
    @service.set_account_container_version_latest(path)
  end

  def list_account_container_workspace_triggers(path:)
    @service.list_account_container_workspace_triggers(path)
    # from here, select the trigger.
    # then, associate the ID of the Trigger as the FiringElement on the Custom Script Tag
  end
end
