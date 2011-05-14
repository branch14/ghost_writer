class CreateLocales < ActiveRecord::Migration
  def self.up
    create_table :locales do |t|
      t.string :code
      t.string :title
      t.references :project

      t.timestamps
    end

    add_index :locales, [:code, :project_id]
  end

  def self.down
    drop_table :locales
  end
end
