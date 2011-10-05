class Mnbackpack::Component < ActiveRecord::Base
  set_table_name 'mn_components'
  has_many :artist_components
  has_many :artists, :through => :artist_components
  has_many :metadata
  has_many :albums, :class_name => 'ComponentType', :conditions => ['type_code = ?', 'ALBUM'], :primary_key => :component_type_id, :foreign_key => :id
  #ruby-1.9.2-p180 :010 > c1 = Component.includes([:component_types]).where(['component_types.type_code = ?', 'ALBUM']).all
  has_many :labels
  
  scope :with_artists, joins(:artists)
  
  searchable do 
    text :title
    time :created_at, :updated_at
    integer :component_type_id
  end
  
  def get_albums(page_limit, page_offset)
    self.connection.execute("CALL getAlbums(#{page_limit}, #{page_offset})")
  end
end