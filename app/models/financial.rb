class Financial < ActiveRecord::Base
  belongs_to :project

  def serializable_hash(options={})
    h = super(options)
    if h['fund_raise_completion']
      days_left = (h['fund_raise_completion'] - Time.now.to_date).to_i
      h['days_left'] = days_left > 0 ? days_left : 0

      h
    end
  end
end
