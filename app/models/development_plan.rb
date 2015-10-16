class DevelopmentPlan < ActiveRecord::Base
  belongs_to :project

  enum flat_type: { unknown: 0, BHK1: 1, BHK2: 2}
end
