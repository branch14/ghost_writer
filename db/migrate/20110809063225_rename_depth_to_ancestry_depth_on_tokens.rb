class RenameDepthToAncestryDepthOnTokens < ActiveRecord::Migration
  def self.up
    rename_column :tokens, :depth, :ancestry_depth
  end

  def self.down
    rename_column :tokens, :ancestry_depth, :depth
  end
end
