class AddAncestryToToken < ActiveRecord::Migration
  def self.up
    add_column :tokens, :ancestry, :string
    add_index :tokens, :ancestry
  end

  def self.down
    remove_column :tokens, :ancestry
    remove_index :tokens, :ancestry
  end
end
