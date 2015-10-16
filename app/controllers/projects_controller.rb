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

    page = params[:page] ? params[:page] : 1
    per_page = params[:per_page] ? params[:per_page] : 10
    @projects = @projects.paginate(:page => page, :per_page => per_page)
    projects = @projects.all.as_json(:include => [:development_plan, :financial] + (params.has_key?("brick_holder_user_id") ? [:brick_holders] : []))

    (0..projects.size-1).each do |i|
      projects[i]['stats'] = get_stats(projects[i]['financial']['fund_raise_start'], projects[i]['financial']['fund_raise_completion'], projects[i]['development_plan']['completion_date'], projects[i]['financial']['num_bricks'])
    end

    render :json => {
               :current_page => @projects.current_page,
               :per_page => @projects.per_page,
               :total_entries => @projects.total_entries,
               :total_pages => @projects.total_pages,
               :projects => projects
           }
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    project = @project.as_json(:include => [:development_plan, :financial])
    project['stats'] = get_stats(project['financial']['fund_raise_start'], project['financial']['fund_raise_completion'], project['development_plan']['completion_date'], project['financial']['num_bricks'])
    render json: project
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

  def get_stats(start_date, fund_end_date, end_date, total_bricks)
    if start_date.class == String
      start_date = start_date.to_date
    end

    if fund_end_date.class == String
      fund_end_date = fund_end_date.to_date
    end

    if end_date.class == String
      end_date = end_date.to_date
    end

    months = (start_date..end_date).map { |d| Date::ABBR_MONTHNAMES[d.month] + ", " + d.year.to_s }.uniq

    stats = {
        land: {},
        flat: {},
        rent_3bhk: {},
        rent_2bhk: {},
        rent_1bhk: {},
        bricks: {}
    }

    land = 2500
    flat = 5000
    rent_3bhk = 21000
    rent_2bhk = 17000
    rent_1bhk = 11000

    months.each do |month|
      sign = (rand - 0.5) > 0 ? 1 : -1

      land = land + sign * rand * 500
      stats[:land][month] = land

      flat = flat + sign * rand * 1000
      stats[:flat][month] = flat

      rent_3bhk = rent_3bhk + sign * rand * 200
      stats[:rent_3bhk][month] = rent_3bhk

      rent_2bhk = rent_2bhk + sign * rand * 200
      stats[:rent_2bhk][month] = rent_2bhk

      rent_1bhk = rent_1bhk + sign * rand * 200
      stats[:rent_1bhk][month] = rent_1bhk
    end

    if start_date < Time.now.to_date

      if fund_end_date > Time.now.to_date
        end_date = Time.now.to_date
        target = total_bricks * (Time.now.to_date - start_date) / (fund_end_date - start_date)
      else
        end_date = fund_end_date
        target = total_bricks
      end

      days = (start_date..end_date).map { |d| Date::ABBR_MONTHNAMES[d.month] + ' ' + d.day.to_s + ', ' + d.year.to_s }.uniq
      bricks = 0
      diff = target/days.size

      days.each do |day|
        random_diff = (rand * diff * 2).to_i
        bricks = bricks + random_diff
        if bricks >= target
          bricks = bricks - random_diff
          stats[:bricks][day] = total_bricks - bricks
          bricks = total_bricks
        else
          stats[:bricks][day] = random_diff
        end
      end

      puts target
      puts bricks

    end

    stats
  end
end
