class RemoveObsoleteStuff < ActiveRecord::Migration
  def self.up
    remove_column :tokens, :raw
    remove_column :tokens, :hashed

    change_column :translations, :hits_counter, :integer, :default => 0
    change_column :translations, :miss_counter, :integer, :default => 0

    add_index :tokens, :full_key

    add_column :tokens, :annotation, :text
  end

  def self.down
    add_column :tokens, :raw, :string
    add_column :tokens, :hashed, :string

    change_column :translations, :hits_counter, :integer
    change_column :translations, :miss_counter, :integer

    remove_index :tokens, :full_key

    remove_column :tokens, :annotation
  end
end
