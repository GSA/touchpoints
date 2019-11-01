FactoryBot.define do
  factory :touchpoint do
    service
    name { "Example Touchpoint" }
    omb_approval_number { rand(10000).to_s }
    expiration_date { Time.now + 2.months }
    delivery_method { "modal" }
    trait :touchpoints_hosted_only do
      delivery_method { "touchpoints-hosted-only" }
    end
    trait :inline do
      delivery_method { "inline" }
      element_selector { "touchpoints-div-id" }
    end
    trait :custom_button_modal do
      delivery_method { "custom-button-modal" }
      element_selector { "existing-website-button-id" }
    end
    trait :with_form do
      association :form, :open_ended_form 
    end
  end
end
