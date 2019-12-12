FactoryBot.define do
  factory :user_role do
    trait :submission_viewer do
      role { UserRole::Role::SubmissionViewer }
    end
    trait :touchpoint_manager do
      role { UserRole::Role::TouchpointManager }
    end
  end
end
