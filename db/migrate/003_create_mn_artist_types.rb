class CreateMnArtistTypes < ActiveRecord::Migration
  def self.up
    create_table :mn_artist_types do |t|
      t.string :type_code
      t.timestamps
    end
  end
  def self.down
    drop_table :mn_artist_types
  end
end