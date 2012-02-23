class AddMissCounterToTranslations < ActiveRecord::Migration
  def self.up
    add_column :translations, :miss_counter, :integer
    rename_column :translations, :hits, :hits_counter
    change_column :translations, :content, :text
    add_column :tokens, :complex, :boolean
  end

  def self.down
    remove_column :translations, :miss_counter
    rename_column :translations, :hits_counter, :hits
    change_column :translations, :content, :string
    remove_column :tokens, :complex
  end
end
