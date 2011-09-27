class Mnbackpack::ArtistType < ActiveRecord::Base
  set_table_name 'mn_artist_types'
  belongs_to :artist_component
end