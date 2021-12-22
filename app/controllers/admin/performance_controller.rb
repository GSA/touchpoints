class Admin::PerformanceController < AdminController
  before_action :set_organization, only: [:edit, :apg]

  def index
  end

  def edit
  end

  def apg
    @apg = Objective.find(params[:apg])
  end

  private

  def set_organization
    @organization = Organization.find_by_id(params[:id]) || Organization.find_by_abbreviation(params[:id].upcase)
  end
end
