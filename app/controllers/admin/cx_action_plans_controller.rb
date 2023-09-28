class Admin::CxActionPlansController < AdminController
  before_action :set_cx_action_plan, only: %i[ show edit update destroy ]

  def index
    @cx_action_plans = CxActionPlan.all
  end

  def show
  end

  def new
    @service_providers = ServiceProvider.all.includes(:organization).order('organizations.name', 'service_providers.name')
    @cx_action_plan = CxActionPlan.new
  end

  def edit
    @service_providers = ServiceProvider.all.includes(:organization).order('organizations.name', 'service_providers.name')
  end

  def create
    @cx_action_plan = CxActionPlan.new(cx_action_plan_params)

    respond_to do |format|
      if @cx_action_plan.save
        format.html { redirect_to admin_cx_action_plan_url(@cx_action_plan), notice: "Cx action plan was successfully created." }
        format.json { render :show, status: :created, location: @cx_action_plan }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @cx_action_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @cx_action_plan.update(cx_action_plan_params)
        format.html { redirect_to admin_cx_action_plan_url(@cx_action_plan), notice: "Cx action plan was successfully updated." }
        format.json { render :show, status: :ok, location: @cx_action_plan }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @cx_action_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @cx_action_plan.destroy

    respond_to do |format|
      format.html { redirect_to cx_action_plans_url, notice: "Cx action plan was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_cx_action_plan
      @cx_action_plan = CxActionPlan.find(params[:id])
    end

    def cx_action_plan_params
      params.require(:cx_action_plan).permit(:service_provider_id, :year, :delivered_current_year, :to_deliver_next_year)
    end
end
