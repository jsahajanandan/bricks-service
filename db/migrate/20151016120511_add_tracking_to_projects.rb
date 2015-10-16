class AddTrackingToProjects < ActiveRecord::Migration
  def change
    add_column :financials, :milestones, :text
    add_column :financials, :current_milestone, :integer
    add_column :financials, :fund_raise_completion, :date
  end
end
