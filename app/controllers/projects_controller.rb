class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :update, :add_bricks, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project

    if params.has_key?("active")
      @projects = @projects.joins(:financial).where("financial.is_active = true")
    end

    if params.has_key?("listing_id")
      @projects = @projects.where(:listing_id => params["listing_id"].to_i)
    end

    if params.has_key?("brick_holder_user_id")
      @projects = @projects.joins(:brick_holders).where("brick_holders.user_id = ? AND brick_holders.num_bricks > 0", params["brick_holder_user_id"])
    end

    render json: @projects.all.as_json(:include => [:development_plan, :financial] + (params.has_key?("brick_holder_user_id") ? [:brick_holders] : []))
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    render json: @project.as_json(:include => [:development_plan, :financial])
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    if @project.save
      render json: @project.as_json(:include => [:development_plan, :financial]), status: :created, location: @project
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    @project = Project.find(params[:id])
    params = project_params
    if (params.has_key?("development_plan_attributes") && @project.development_plan.present?)
      params["development_plan_attributes"]["id"] = @project.development_plan.id
    end
    if (params.has_key?("financial_attributes") && @project.financial.present?)
      params["financial_attributes"]["id"] = @project.financial.id
    end
    if @project.update(params)
      head :no_content
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def add_bricks
    if (params[:user_id] && params[:num_bricks])
      if @project.financial.fund_raise_completion >= Date.today
        render json: {error: "project still in fund raise period"}, status: :unprocessable_entity and return
      end
      existing_bricks = @project.brick_holders.where(:user_id => params[:user_id].to_i)
      if existing_bricks.count > 0
        brick_holder = existing_bricks.first
        num_bricks = existing_bricks.first.num_bricks
        saved = brick_holder.update({:user_id => params[:user_id], :num_bricks => num_bricks + params[:num_bricks].to_i})
      else
        brick_holder = @project.brick_holders.build({:user_id => params[:user_id], :num_bricks => params[:num_bricks]})
        saved = brick_holder.save()
      end
      if saved
        render json: brick_holder, status: :ok
      else
        render json: @project.errors, status: :unprocessable_entity
      end
    else
      render json: {error: "params incorrect"}, status: :bad_request
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy

    head :no_content
  end

  private

    def set_project
      @project = Project.find(params[:id])
    end

    def project_params
      params.require(:project).permit(:listing_id, :project_tag,
                                      development_plan_attributes: [:num_floors, :num_flats, :flat_type, :flat_area, :flat_selling_price, :completion_date],
                                      financial_attributes: [:land_cost, :investment_sum_required, :num_bricks, :brick_value, :personal_investment, :roi_pitch, :is_active, :milestones, :current_milestone, :fund_raise_start, :fund_raise_completion])
    end
end
