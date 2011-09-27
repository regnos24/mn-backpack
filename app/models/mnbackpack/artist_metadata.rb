class Mnbackpack::ArtistMetadata < ActiveRecord::Base
  set_table_name 'mn_artist_metadata'
  belongs_to :artist
end