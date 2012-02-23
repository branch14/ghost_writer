class CreateTranslations < ActiveRecord::Migration
  def self.up
    create_table :translations do |t|
      t.string :content
      t.integer :hits
      t.references :token
      t.references :locale

      t.timestamps
    end

    add_index :translations, [:token_id, :locale_id]
  end

  def self.down
    drop_table :translations
  end
end
