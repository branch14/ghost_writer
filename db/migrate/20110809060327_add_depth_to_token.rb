class AddDepthToToken < ActiveRecord::Migration
  def self.up
    add_column :tokens, :depth, :integer
    add_index :tokens, :depth
  end

  def self.down
    remove_column :tokens, :depth
    remove_index :tokens, :depth
  end
end
