class AddNotesToTokens < ActiveRecord::Migration
  def self.up
    add_column :tokens, :notes, :text
  end

  def self.down
    remove_column :tokens, :notes
  end
end
