class AddIndexForTranslationsContent < ActiveRecord::Migration
  def self.up
    add_index :translations, [:content, :locale_id]
  end

  def self.down
  end
end
