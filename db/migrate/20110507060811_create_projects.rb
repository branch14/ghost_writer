class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :title
      t.string :permalink

      t.timestamps
    end

    add_index :projects, :permalink
  end

  def self.down
    drop_table :projects
  end
end
