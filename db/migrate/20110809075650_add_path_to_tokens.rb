class AddPathToTokens < ActiveRecord::Migration
  def self.up
    add_column :tokens, :path, :string
  end

  def self.down
    remove_column :tokens, :path
  end
end
