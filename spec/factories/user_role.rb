# frozen_string_literal: true

FactoryBot.define do
  factory :user_role do
    trait :response_viewer do
      role { UserRole::Role::ResponseViewer }
    end
    trait :form_manager do
      role { UserRole::Role::FormManager }
    end
  end
end
