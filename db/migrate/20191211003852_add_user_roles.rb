class AddUserRoles < ActiveRecord::Migration[5.2]
  def down
    drop_table "user_roles"
  end

  def up
    create_table "user_roles", force: :cascade do |t|
      t.integer "user_id", null: false
      t.integer "service_id"
      t.integer "touchpoint_id"
      t.integer "form_id"
      t.string "role"

      t.timestamps
    end

    # Migrate ServiceManager and Submission Viewers User Service
    # permissions to User Roles
    UserService.all.each do |user_service|
      UserRole.create!({
        user_id: user_service.user_id,
        service_id: user_service.service_id,
        role: user_service.role
      })
    end

    puts "created #{UserRole.count} UserRoles from UserServices"
  end
end
