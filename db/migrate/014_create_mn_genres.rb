class CreateMnGenres < ActiveRecord::Migration
  def self.up
    create_table :mn_genres do |t|
      t.string :name, :category, :genre_type
      t.integer :parent_id
      t.timestamps
    end
  end
  def self.down
    drop_table :mn_genres
  end
end