class BrickHolder < ActiveRecord::Base
  validates :num_bricks, numericality: { greater_than_or_equal_to: 0 }
end
