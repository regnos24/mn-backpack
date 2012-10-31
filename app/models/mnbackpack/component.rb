class Mnbackpack::Component < ActiveRecord::Base
  set_table_name 'mn_components'
  attr_accessor :tracks, :album
  has_many :artist_components, :class_name => 'Mnbackpack::ArtistComponent'
  has_many :artists, :through => :artist_components, :class_name => 'Mnbackpack::Artist'
  has_many :metadata, :class_name => 'Mnbackpack::Metadata'
  #has_many :albums, :class_name => 'Mnbackpack::ComponentType', :conditions => ['type_code = ?', 'ALBUM'], :primary_key => :component_type_id, :foreign_key => :id
  #ruby-1.9.2-p180 :010 > c1 = Component.includes([:component_types]).where(['component_types.type_code = ?', 'ALBUM']).all
  has_many :labels, :class_name => 'Mnbackpack::Label'
  has_one :retail_prices, :class_name => 'Mnbackpack::RetailPrice'
  has_many :component_parents, :class_name => 'Mnbackpack::ComponentParent', :primary_key => 'id', :foreign_key => 'parent_component_id'
  
  searchable do 
    text :title
    time :created_at, :updated_at
    integer :component_type_id
  end
  
  def self.track_album(id)
    joins(:component_parents).where("child_component_id = ?", id)
  end
  
  def album?
    c = components
    unless(c.blank?)
      @tracks = c
      @album = false
      true
    else
      @tracks = []
      @album = Mnbackpack::Component.track_album(self.id)
      false
    end
  end
  
  def get_albums(page_limit, page_offset)
    self.connection.execute("CALL getAlbums(#{page_limit}, #{page_offset})")
  end
end