FactoryBot.define do
  factory :user_service
  trait :submission_viewer do
    role { UserService::Role::SubmissionViewer }
  end
  trait :service_manager do
    role { UserService::Role::ServiceManager }
  end
end
