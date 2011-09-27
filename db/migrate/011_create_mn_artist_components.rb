class CreateMnArtistComponents < ActiveRecord::Migration
  def self.up
    create_table :mn_artist_components do |t|
      t.references :component, :artist, :artist_type
      t.string :ranking
      t.text :supplemental
      t.timestamps
    end
  end
  def self.down
    drop_table :mn_artist_components
  end
end