# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
projects_saved = false
Project.transaction do
  listing_ids = 1..51
  listing_ids.each do |listing_id|
    x = rand*15
    flat_area = 900 + (rand * 16).to_i * 10
    num_floors = (rand * 3).to_i + 4
    num_flats = (rand * 6).to_i + 10
    flat_selling_price = (((rand * 110).to_i) / 10.0) * 100000 + 5000000
    t1 = Time.local(2015, 12, 12)
    t2 = Time.local(2017, 12, 12)
    diff = rand * (t2 - t1)
    rt = t1 + diff
    fund_raise_completion = rt.strftime("%Y-%m-%d")
    rt = t1 + 2 * diff
    completion_time = rt.strftime("%Y-%m-%d")

    milestones = [
        { name: 'Basement', fund: 20 },
        { name: 'First Floor', fund: 20 },
        { name: 'Second Floor', fund: 20 },
        { name: 'Third Floor', fund: 20 },
        { name: 'Finishing', fund: 20 },
    ]

    (0..4).each do |i|
      rt = t1 + diff + diff*(i+1)/5
      milestones[i][:date] = rt.strftime("%Y-%m-%d")
    end

    land_cost = ((rand * 180).to_i / 10) * 1000000 + 2000000
    investment_sum_required = [0.8, 0.7, 0.6][rand * 3] * (flat_selling_price * num_flats)
    personal_investment = land_cost + [0.1, 0.2, 0.3][rand * 3] * investment_sum_required
    brick_value = ((rand * 5).to_i) * 1000 + 1000
    num_bricks = (investment_sum_required + land_cost) / brick_value
    is_active = true
    #project_tag = %w(UNKNOWN, HOT_INVESTMENT, RISING, POPULAR_LOCATION, NEW)[rand * 5]
    #flat_type = %w(UNKNOWN, BHK, BHK2, BHK3])[rand * 3]
    project_tag = (rand * 4).to_i + 1
    flat_type = (rand * 3).to_i + 1

    params = {
            listing_id: listing_id,
            project_tag: project_tag,
            development_plan_attributes: {
                num_floors: num_floors,
                num_flats: num_flats,
                flat_type: flat_type,
                flat_area: flat_area,
                flat_selling_price: flat_selling_price,
                completion_date: completion_time
            },
            financial_attributes: {
                land_cost: land_cost,
                investment_sum_required: investment_sum_required,
                num_bricks: num_bricks,
                brick_value: brick_value,
                personal_investment: personal_investment,
                roi_pitch: "ROI ROI ROI ROI ROI!", # Replace
                is_active: true,
                fund_raise_completion: fund_raise_completion,
                milestones: milestones
            }
        }
    Project.create!(params)
    projects_saved = true
  end
end
if projects_saved
  puts "Created projects."
else
  puts "Oops! Something went wrong!"
end









