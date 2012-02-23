class AddKeyToTokens < ActiveRecord::Migration
  def self.up
    add_column :tokens, :key, :string
  end

  def self.down
    remove_column :tokens, :key
  end
end
