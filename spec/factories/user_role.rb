FactoryBot.define do
  factory :user_role do
    trait :submission_viewer do
      role { UserRole::Role::SubmissionViewer }
    end
    trait :form_manager do
      role { UserRole::Role::FormManager }
    end
  end
end
