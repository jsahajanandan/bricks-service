# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Project.delete_all
Financial.delete_all
DevelopmentPlan.delete_all
BrickHolder.delete_all

# Get a random date within the range [t1, t2]
def get_random_date(t1, t2)
  diff = rand * (t2 - t1)
  rt = t1 + diff
  rt.strftime("%Y-%m-%d")
end

projects_saved = false
projects = 0
project_with_brick_holders = 0
roi_pitch = 'We are building a multi-storeyed, amenity-enabled standalone building that will home 12 apartments. The land on which the building will be built is title and litigation free and located in the Koramangala neighborhood in Bangalore - one of the hottest localities in the city with the highest rate of appreciation in real estate for the last 10 years and forecasted to only see further appreciation as Bangalore continues to attract more companies and people. If you are looking to invest in a property that sees rapid appreciation and equally quick liquidity, you would be interested in investing here.'
Project.transaction do
  projects_for_bricks = []
  listing_ids = 1..51
  listing_ids.each do |listing_id|
    x = rand*15
    flat_area = 900 + (rand * 16).to_i * 10
    num_floors = (rand * 3).to_i + 4
    num_flats = (rand * 6).to_i + 10
    flat_selling_price = (((rand * 110).to_i) / 10.0) * 100000 + 5000000
    completion_time = get_random_date(Time.local(2016, 06, 06), Time.local(2017, 12, 12))
    fund_raise_start = get_random_date(Time.local(2015, 10, 01), Time.local(2015, 10, 31))
    fund_raise_completion = (fund_raise_start.to_time + (rand * 20 + 10).days).strftime("%Y-%m-%d")

    milestones = [
        {name: 'Basement', fund: 20},
        {name: 'First Floor', fund: 20},
        {name: 'Second Floor', fund: 20},
        {name: 'Third Floor', fund: 20},
        {name: 'Finishing', fund: 20},
    ]

    milestone_start_date = fund_raise_completion.to_time + 10.days
    diff = (completion_time.to_time - milestone_start_date)/5

    (0..3).each do |i|
      rt = milestone_start_date + diff * (i + 1)
      milestones[i][:date] = rt.strftime("%Y-%m-%d")
    end
    milestones[4][:date] = completion_time

    land_cost = ((rand * 180).to_i / 10) * 1000000 + 2000000
    investment_sum_required = [0.8, 0.7, 0.6][rand * 3] * (flat_selling_price * num_flats)
    personal_investment = land_cost + [0.1, 0.2, 0.3][rand * 3] * investment_sum_required
    brick_value = ((rand * 5).to_i) * 1000 + 1000
    num_bricks = (investment_sum_required + personal_investment + land_cost) / brick_value
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
            roi_pitch: roi_pitch,
            is_active: true,
            fund_raise_start: fund_raise_start,
            fund_raise_completion: fund_raise_completion,
            milestones: milestones
        }
    }
    p = Project.create!(params)
    if p.financial.fund_raise_completion < Date.today
      projects_for_bricks.push(p)
    end
    projects += 1
  end
  count = projects_for_bricks.count
  (2251..2257).each do |user_id|
    num = (rand * 5 + 1).to_i
    num.times do |i|
      p = projects_for_bricks[rand * count]
      num_bricks = rand * 20 + 1
      if p.financial.num_bricks > num_bricks && BrickHolder.where({:user_id => user_id, :project_id => p.id}).count == 0
        p.brick_holders.create!({:user_id => user_id, :num_bricks => num_bricks})
        project_with_brick_holders += 1
      end
    end
    projects_saved = true
  end
end
if projects_saved
  puts "Created #{projects} projects. Projects with brick holders = #{project_with_brick_holders}"
else
  puts "Oops! Something went wrong!"
end









