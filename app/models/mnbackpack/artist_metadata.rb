class Mnbackpack::ArtistMetadata < ActiveRecord::Base
  set_table_name 'mn_artist_metadata'
  belongs_to :artist, :class_name => 'Mnbackpack::Artist'
end