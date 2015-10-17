class Project < ActiveRecord::Base
  has_one :development_plan, dependent: :destroy
  has_one :financial, dependent: :destroy
  has_many :brick_holders, dependent: :destroy

  accepts_nested_attributes_for :development_plan
  accepts_nested_attributes_for :financial

  enum project_tag: {UNKNOWN: 0, HOT_INVESTMENT: 1, RISING: 2, POPULAR_LOCATION: 3, NEW: 4}
  def serializable_hash(options={})
    h = super(options)
    h['num_backers'] = (rand * 10000).to_i
    h['fund_raised'] = h['num_backers'] * financial.brick_value
    h['fund_progress'] = (h['fund_raised']/financial.investment_sum_required * 100).to_i
    h['fund_progress'] = 100 if h['fund_progress'] > 100
    h['project_tag'] = h['project_tag'].gsub('_', ' ')
    h
  end
end

