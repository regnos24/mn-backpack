class CreateMnArtistMetadata < ActiveRecord::Migration
  def self.up
    create_table :mn_artist_metadata do |t|
      t.references :artist, :metadata_type
      t.string :value_desc, :title, :publish_date, :author
      t.timestamps
    end
  end
  def self.down
    drop_table :mn_artist_metadata
  end
end