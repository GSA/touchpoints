class ProfileController < ApplicationController
  def show
    if current_user.blank?
      redirect_to admin_root_path
    end
    @api_key_warning = (current_user.api_key_updated_at.present? and current_user.api_key_updated_at < (Time.now - 6.months) ) ? true : false
  end

  def update
  	current_user.update_attributes!(user_params)
    redirect_to admin_root_path, notice: "User profile updated"
  end

  def generate_api_key
    current_user.set_api_key
    redirect_to controller: :profile, action: :show
  end

  def delete_api_key
    current_user.unset_api_key
    redirect_to controller: :profile, action: :show
  end

private

  def user_params
  	params.require(:user).permit(:time_zone)
  end
end
