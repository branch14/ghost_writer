class AddActiveToTranslation < ActiveRecord::Migration
  def self.up
    add_column :translations, :active, :boolean, :default => true
  end

  def self.down
    remove_column :translations, :active
  end
end
