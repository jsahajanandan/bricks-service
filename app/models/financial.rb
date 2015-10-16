class Financial < ActiveRecord::Base
  belongs_to :project

  def serializable_hash(options={})
    h = super(options)
    if h['fund_raise_completion']
      if (fund_raise_start > Time.now.to_date)
        days_to_start = (h['fund_raise_start'] - Time.now.to_date).to_i
        h['days_to_start'] = days_to_start
      else
        days_left = (h['fund_raise_completion'] - Time.now.to_date).to_i
        h['days_left'] = days_left > 0 ? days_left : 0
      end
      h
    end
  end
end
