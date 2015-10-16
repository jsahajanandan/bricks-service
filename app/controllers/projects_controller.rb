class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :update, :destroy]

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

    render json: @projects.all.as_json(:include => [:development_plan, :financial])
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
                                      financial_attributes: [:land_cost, :investment_sum_required, :num_bricks, :brick_value, :personal_investment, :roi_pitch, :is_active])
    end

    def get_stats(start_date, fund_end_date , end_date, total_bricks)
      puts start_date
      puts fund_end_date
      puts end_date

      months = (start_date..end_date).map{|d| Date::ABBR_MONTHNAMES[d.month] + ", " +  d.year.to_s }.uniq

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

        days = (start_date..end_date).map{|d| Date::ABBR_MONTHNAMES[d.month] + ' ' +  d.day.to_s + ', ' + d.year.to_s }.uniq
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
