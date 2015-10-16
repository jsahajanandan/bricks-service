class Project < ActiveRecord::Base
  has_one :development_plan, dependent: :destroy
  has_one :financial, dependent: :destroy

  accepts_nested_attributes_for :development_plan
  accepts_nested_attributes_for :financial

  enum project_tag: {UNKNOWN: 0, HOT_INVESTMENT: 1, RISING: 2, POPULAR_LOCATION: 3, NEW: 4}
end

