# frozen_string_literal: true

class ProfileController < AdminController
  before_action :ensure_user

  def show; end

  def update
    if current_user.update(user_params)
      redirect_to profile_path, notice: 'User profile updated'
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :api_key,
      :time_zone,
      :first_name,
      :last_name,
      :position_title,
    )
  end
end
