class Mnbackpack::Metadata < ActiveRecord::Base
  set_table_name 'mn_metadata'
  belongs_to :components, :class_name => 'Mnbackpack::Component'
  has_many :metadata_types, :class_name => 'Mnbackpack::MetadataTypes'
end