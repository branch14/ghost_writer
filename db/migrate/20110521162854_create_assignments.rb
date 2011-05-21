class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      t.reference :user
      t.reference :project
      t.string :role

      t.timestamps
    end
  end

  def self.down
    drop_table :assignments
  end
end
