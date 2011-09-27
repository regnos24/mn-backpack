class Mnbackpack::Artist < ActiveRecord::Base
  set_table_name 'mn_artists'
  has_many :artist_components
  has_many :components, :through => :artist_components
  has_many :albums
  has_many :artist_metadata, :class_name => "ArtistMetadata"
  has_one :artist_type, :through => :artist_components  
  
  def to_json
    super(:except => :password)
  end
  
  def self.get_artists(page_limit, page_offset)
    self.connection.execute("CALL getArtists(#{page_limit}, #{page_offset})")
  end
end