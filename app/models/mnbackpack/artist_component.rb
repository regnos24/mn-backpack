class Mnbackpack::ArtistComponent < ActiveRecord::Base
  set_table_name 'mn_artist_components'
  belongs_to :artist
  belongs_to :component
  has_one :artist_type, :primary_key => :artist_type_id, :foreign_key => :id
end