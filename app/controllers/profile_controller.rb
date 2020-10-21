class ProfileController < ApplicationController
  def show
    if current_user.blank?
      redirect_to admin_root_path
    end
  end

  def update
  	current_user.update_attributes!(user_params)
    redirect_to admin_root_path, notice: "User profile updated"
  end

private

  def user_params
  	params.require(:user).permit(:time_zone)
  end
end
