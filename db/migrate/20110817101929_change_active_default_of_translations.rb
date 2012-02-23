class ChangeActiveDefaultOfTranslations < ActiveRecord::Migration
  def self.up
    change_column :translations, :active, :boolean, :default => false
  end

  def self.down
    change_column :translations, :active, :boolean, :default => true
  end
end
