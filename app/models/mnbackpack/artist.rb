class Mnbackpack::Artist < ActiveRecord::Base
  set_table_name 'mn_artists'
  default_scope where(artist_category: "MUSIC")
  has_many :artist_components
  has_many :components, :through => :artist_components
  has_many :albums
  has_many :artist_metadata, :class_name => "ArtistMetadata"
  has_one :artist_type, :through => :artist_components
  
  searchable do 
    text :name, :sort_name
    integer :id
  end
  
  def self.albums(mnetid)
    mn = Mnbackpack::Request.new
    mn.single('Artist.GetAlbums', {"MnetId" => "#{mnetid}", "IncludeExplicit" => "false", "Pagesize" => "20"})
  end
  
  def self.tracks(mnetid)
    mn = Mnbackpack::Request.new
    mn.single('Artist.GetTracks', {"MnetId" => "#{mnetid}", "IncludeExplicit" => "false", "Pagesize" => "20"})
  end
  
  def to_json
    super(:except => :password)
  end
  
  def self.get_artists(page_limit, page_offset)
    self.connection.execute("CALL getArtists(#{page_limit}, #{page_offset})")
  end
end