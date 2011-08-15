class AddApiKeyToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :api_key, :string
  end
end
