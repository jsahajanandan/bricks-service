class CreateBrickHolders < ActiveRecord::Migration
  def change
    create_table :brick_holders do |t|
      t.belongs_to :project
      t.integer :user_id
      t.integer :num_bricks
      t.timestamps null: false
    end
  end
end
