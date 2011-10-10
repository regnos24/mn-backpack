class Mnbackpack::Artist < ActiveRecord::Base
  set_table_name 'mn_artists'
  default_scope where(artist_category: "MUSIC")
  has_many :artist_components, :class_name => 'Mnbackpack::ArtistComponent'
  has_many :components, :through => :artist_components, :class_name => 'Mnbackpack::Component'
  has_many :artist_metadata, :class_name => "Mnbackpack::ArtistMetadata"
  has_one :artist_type, :through => :artist_components, :class_name => 'Mnbackpack::ArtistType'
  
  searchable do 
    text :name, :boost => 5
    text :sort_name
    integer :id
    #integer :component_ids, :multiple => true, :references => Mnbackpack::Component
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
  
  def search_class
      self.class.name#.underscore.humanize.split(" ").each{|word| word.capitalize!}.join(" ")
  end
  
  def self.get_artists(page_limit, page_offset)
    self.connection.execute("CALL getArtists(#{page_limit}, #{page_offset})")
  end
end