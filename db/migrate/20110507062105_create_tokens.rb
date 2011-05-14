class CreateTokens < ActiveRecord::Migration
  def self.up
    create_table :tokens do |t|
      t.string :raw
      t.string :hashed
      t.references :project

      t.timestamps
    end

    add_index :tokens, [:raw, :project_id]
    add_index :tokens, [:hashed, :project_id]
  end

  def self.down
    drop_table :tokens
  end
end
