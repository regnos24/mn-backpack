class Mnbackpack::MetadataType < ActiveRecord::Base
  set_table_name 'mn_metadata_types'
  belongs_to :artist_metadata, :class_name => 'Mnbackpack::ArtistMetadata'
  belongs_to :metadatas, :class_name => 'Mnbackpack::Metadata'
end