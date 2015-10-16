class CreateDevelopmentPlans < ActiveRecord::Migration
  def change
    create_table :development_plans do |t|
      t.belongs_to :project
      t.integer :num_floors, null: false
      t.integer :num_flats, null: false
      t.integer :flat_type , limit: 1, default: 0
      t.float :flat_area, null: false
      t.decimal :flat_selling_price, :precision => 20, :scale => 2, null: false
      t.date :completion_date, null: false
      t.timestamps null: false
    end
  end
end
