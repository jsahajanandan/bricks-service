class CreateFinancials < ActiveRecord::Migration
  def change
    create_table :financials do |t|
      t.belongs_to :project
      t.decimal :land_cost, :precision => 20, :scale => 2, null: false
      t.decimal :investment_sum_required, :precision => 20, :scale => 2, null: false
      t.integer :num_bricks, null: false
      t.decimal :brick_value, :precision => 20, :scale => 2, null: false
      t.decimal :personal_investment, :precision => 20, :scale => 2, null: false
      t.text :roi_pitch, null: false
      t.boolean :is_active

      t.timestamps null: false
    end
    add_index :financials, :project_id, unique: true
  end
end
