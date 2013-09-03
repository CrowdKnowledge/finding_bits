class CreateTopRepos < ActiveRecord::Migration
  def change
    create_table :top_repos do |t|
      t.string :language
      t.string :full_name
      t.string :html_url
      t.integer :forks
      t.integer :watchers

      t.timestamps
    end
  end
end
