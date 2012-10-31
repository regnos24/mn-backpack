class Mnbackpack::ArtistComponent < ActiveRecord::Base
  set_table_name 'mn_artist_components'
  belongs_to :artist, :class_name => 'Mnbackpack::Artist'
  belongs_to :component, :class_name => 'Mnbackpack::Component'
  has_one :artist_type, :primary_key => :artist_type_id, :foreign_key => :id, :class_name => 'Mnbackpack::ArtistType'
end