class CreateMnArtists < ActiveRecord::Migration
  def self.up
    # <Id>50444</Id>
    #       <Amg-Id>P   703642</Amg-Id>
    #       <Name>Grafh</Name>
    #       <Sort-Name>Grafh</Sort-Name>
    #       <Artist-Category>MUSIC</Artist-Category>
    #       <Created-Date>2004-01-26</Created-Date>
    #       <Last-Updated-Date>2005-05-14</Last-Updated-Date>
    create_table :mn_artists do |t|
      t.string :name, :amg_id, :sort_name, :artist_category
      t.timestamps
    end
  end
  def self.down
    drop_table :mn_artists
  end
end