class Admin::GoalsController < AdminController
  before_action :set_goal, only:
    %i[show
       edit
       update
       update_organization_id
       update_name
       update_statement
       update_description
       update_position
       update_tags
       update_users
       update_four_year_goal
       update_parent_id
       goal_targets
       goal_objectives
       destroy
       add_tag
       remove_tag]

  before_action :set_goal_tags, only: [:show, :add_tag, :remove_tag]

  def index
    @goals = Goal.all
  end

  def show; end

  def new
    @goal = Goal.new
    @goal.organization_id = current_user.organization_id
    @goal.name = 'New Goal'
    @goal.save!
  end

  def edit; end

  def create
    @goal = Goal.new(goal_params)

    if @goal.save
      redirect_to admin_goal_path(@goal), notice: 'Goal was successfully created.'
    else
      render :new
    end
  end

  def update
    if @goal.update(goal_params)
      redirect_to admin_goal_path(@goal), notice: 'Goal was successfully updated.'
    else
      render :edit
    end
  end

  def add_tag
    @goal.tag_list.add(goal_params[:tag_list].split(','))
    @goal.save
  end

  def remove_tag
    @goal.tag_list.remove(goal_params[:tag_list].split(','))
    @goal.save
  end

  def update_organization_id
    @goal.update!(update_organization_id: params[:organization_id])
    render json: @goal
  end

  def update_name
    @goal.update!(name: params[:name])
    render json: @goal
  end

  def update_statement
    @goal.update!(goal_statement: params[:goal_statement])
    render json: @goal
  end

  def update_description
    @goal.update!(description: params[:description])
    render json: @goal
  end

  def update_position
    @goal.update!(position: params[:position])
    render json: @goal
  end

  def update_tags
    @goal.update!(tags: params[:tags].split(" "))
    render json: @goal
  end

  def update_users
    @goal.update!(users: [params[:users].to_i])
    render json: @goal
  end

  def update_four_year_goal
    @goal.update!(four_year_goal: params[:four_year_goal])
    render json: @goal
  end

  def update_parent_id
    @goal.update!(parent_id: params[:parent_id])
    render json: @goal
  end

  def destroy
    @goal.destroy
    redirect_to admin_goals_url, notice: 'Goal was successfully destroyed.'
  end

  def goal_targets
  end

  def goal_objectives
  end

  private

  def set_goal
    @goal = Goal.find(params[:id])
  end

  def set_goal_tags
    @goal_tags_for_select = Goal::TAGS
  end

  def goal_params
    params.require(:goal).permit(
      :organization_id,
      :name,
      :description,
      :statement,
      :tags,
      :users,
      :four_year_goal,
      :parent_id,
      :tag_list,
    )
  end
end
