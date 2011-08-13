class RenamePathToFullKeyOnTokens < ActiveRecord::Migration
  def self.up
    rename_column :tokens, :path, :full_key
  end

  def self.down
    rename_column :tokens, :full_key, :path
  end
end
