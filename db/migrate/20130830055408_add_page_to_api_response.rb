class AddPageToApiResponse < ActiveRecord::Migration
  def change
    add_column :api_responses, :page, :integer
  end
end
