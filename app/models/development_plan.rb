class DevelopmentPlan < ActiveRecord::Base
  belongs_to :project

  # There can be other flat types too otherwise store just numbers/ or types in separate db.
  enum flat_type: { UNKNOWN: 0, BHK1: 1, BHK2: 2, BHK3: 3}

  def serializable_hash(options={})
    h = super(options)
    if h['flat_type'].starts_with?('BHK') && h['flat_type'][3]
      h['flat_type'] = h['flat_type'][3] + 'BHK'
    end
    h
  end
end
