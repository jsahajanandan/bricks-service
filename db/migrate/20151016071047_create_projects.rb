class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.integer :user_id, null: false
      t.integer :listing_id, null: false
      t.integer :project_tag, limit: 1, default: 0
      t.timestamps null: false
    end
  end
end
