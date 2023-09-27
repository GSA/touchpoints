class CxActionPlansController < ApplicationController
  before_action :set_cx_action_plan, only: %i[ show edit update destroy ]

  # GET /cx_action_plans or /cx_action_plans.json
  def index
    @cx_action_plans = CxActionPlan.all
  end

  # GET /cx_action_plans/1 or /cx_action_plans/1.json
  def show
  end

  # GET /cx_action_plans/new
  def new
    @cx_action_plan = CxActionPlan.new
  end

  # GET /cx_action_plans/1/edit
  def edit
  end

  # POST /cx_action_plans or /cx_action_plans.json
  def create
    @cx_action_plan = CxActionPlan.new(cx_action_plan_params)

    respond_to do |format|
      if @cx_action_plan.save
        format.html { redirect_to cx_action_plan_url(@cx_action_plan), notice: "Cx action plan was successfully created." }
        format.json { render :show, status: :created, location: @cx_action_plan }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @cx_action_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cx_action_plans/1 or /cx_action_plans/1.json
  def update
    respond_to do |format|
      if @cx_action_plan.update(cx_action_plan_params)
        format.html { redirect_to cx_action_plan_url(@cx_action_plan), notice: "Cx action plan was successfully updated." }
        format.json { render :show, status: :ok, location: @cx_action_plan }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @cx_action_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cx_action_plans/1 or /cx_action_plans/1.json
  def destroy
    @cx_action_plan.destroy

    respond_to do |format|
      format.html { redirect_to cx_action_plans_url, notice: "Cx action plan was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cx_action_plan
      @cx_action_plan = CxActionPlan.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cx_action_plan_params
      params.require(:cx_action_plan).permit(:service_provider_id, :year, :delivered_current_year, :to_deliver_next_year)
    end
end
