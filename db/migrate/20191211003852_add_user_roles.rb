# frozen_string_literal: true

class AddUserRoles < ActiveRecord::Migration[5.2]
  def down
    drop_table 'user_roles'
  end

  def up
    create_table 'user_roles', force: :cascade do |t|
      t.integer 'user_id', null: false
      t.integer 'service_id'
      t.integer 'touchpoint_id'
      t.integer 'form_id'
      t.string 'role'

      t.timestamps
    end

    # Migrate ServiceManager and SubmissionViewers UserServices
    # permissions to User Roles
    Service.all.each do |service|
      Rails.logger.debug { "Service #{service.name}" }
      service.user_services.each do |user_service|
        Rails.logger.debug { "UserService #{user_service.id}" }
        service.touchpoints.each do |touchpoint|
          Rails.logger.debug { "Touchpoint #{touchpoint.name}" }
          if user_service.role == UserService::Role::ServiceManager
            @translated_role = UserRole::Role::TouchpointManager
          elsif user_service.role == UserService::Role::SubmissionViewer
            @translated_role = UserRole::Role::SubmissionViewer
          end

          UserRole.create!({
                             user_id: user_service.user_id,
                             touchpoint_id: touchpoint.id,
                             role: @translated_role
                           })
        end
      end
    end

    Rails.logger.debug { "created #{UserRole.count} UserRoles from UserServices" }
  end
end
