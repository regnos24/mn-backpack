class CreateMnForeignKeyRelationships < ActiveRecord::Migration
  def self.up
    #ArtistComponents Foreign Keys
    execute "ALTER TABLE mn_artist_components ADD CONSTRAINT fk_artist_components_components FOREIGN KEY (component_id) REFERENCES mn_components(id)"
    execute "ALTER TABLE mn_artist_components ADD CONSTRAINT fk_artist_components_artists FOREIGN KEY (artist_id) REFERENCES mn_artists(id)"
    execute "ALTER TABLE mn_artist_components ADD CONSTRAINT fk_artist_components_artist_types FOREIGN KEY (artist_type_id) REFERENCES mn_artist_types(id)"
    
    #ArtistMetadata Foreign Keys 
    execute "ALTER TABLE mn_artist_metadata ADD CONSTRAINT fk_artist_metadata_artists FOREIGN KEY (artist_id) REFERENCES mn_artists(id)"
    execute "ALTER TABLE mn_artist_metadata ADD CONSTRAINT fk_artist_metadata_metadata_type FOREIGN KEY (metadata_type_id) REFERENCES mn_metadata_types(id)"
    
    #ComponentActions Foreign Keys
    execute "ALTER TABLE mn_component_actions ADD CONSTRAINT fk_component_actions_components FOREIGN KEY (component_id) REFERENCES mn_components(id)"        
    
    #ComponentParent Foreign Keys
    execute "ALTER TABLE mn_component_parents ADD CONSTRAINT fk_component_parents_components FOREIGN KEY (parent_component_id) REFERENCES mn_components(id)"
    execute "ALTER TABLE mn_component_parents ADD CONSTRAINT fk_component_children_components FOREIGN KEY (child_component_id) REFERENCES mn_components(id)"
    
    #Components Foreign Keys
    execute "ALTER TABLE mn_components ADD CONSTRAINT fk_component_labels FOREIGN KEY (label_id) REFERENCES mn_labels(id)"
    execute "ALTER TABLE mn_components ADD CONSTRAINT fk_component_component_types FOREIGN KEY (component_type_id) REFERENCES mn_component_types(id)"
    
    #Labels Foreign Keys
    execute "ALTER TABLE mn_labels ADD CONSTRAINT fk_labels_label_owners FOREIGN KEY (label_owner_id) REFERENCES mn_label_owners(id)"
    
    #MediaFiles Foreign Keys
    execute "ALTER TABLE mn_media_files ADD CONSTRAINT fk_media_files_components FOREIGN KEY (component_id) REFERENCES mn_components(id)"
    #execute "ALTER TABLE media_files ADD CONSTRAINT fk_media_files_asset_types FOREIGN KEY (asset_code) REFERENCES asset_types(asset_code)"
    
    #Metadata Foreign Keys
    execute "ALTER TABLE mn_metadata ADD CONSTRAINT fk_metadata_components FOREIGN KEY (component_id) REFERENCES mn_components(id)"
    execute "ALTER TABLE mn_metadata ADD CONSTRAINT fk_metadata_metadata_types FOREIGN KEY (metadata_type_id) REFERENCES mn_metadata_types(id)"
    
    #RelatedComponents Foreign Keys
    execute "ALTER TABLE mn_related_components ADD CONSTRAINT fk_related_components_components FOREIGN KEY (component_id) REFERENCES mn_components(id)"
    
    #Wholesale Foreign Keys
    execute "ALTER TABLE mn_wholesale_prices ADD CONSTRAINT fk_wholesale_prices_components FOREIGN KEY (component_id) REFERENCES mn_components(id)"
    execute "ALTER TABLE mn_wholesale_prices ADD CONSTRAINT fk_wholesale_prices_price_scopes_types FOREIGN KEY (price_scope_id) REFERENCES mn_price_scopes(id)"
    execute "ALTER TABLE mn_wholesale_prices ADD CONSTRAINT fk_wholesale_prices_territories FOREIGN KEY (territory_id) REFERENCES mn_territories(id)"
    execute "ALTER TABLE mn_wholesale_prices ADD CONSTRAINT fk_wholesale_prices_currencies FOREIGN KEY (currency_id) REFERENCES mn_currencies(id)"
   #Asset-Type Foreign Keys
    execute "ALTER TABLE mn_asset_types ADD CONSTRAINT fk_asset_types_price_scopes_types FOREIGN KEY (price_scope_id) REFERENCES mn_price_scopes(id)"
    #RetailPrices Foreign Keys
    execute "ALTER TABLE mn_retail_prices ADD CONSTRAINT fk_retail_prices_components FOREIGN KEY (component_id) REFERENCES mn_components(id)"
    execute "ALTER TABLE mn_retail_prices ADD CONSTRAINT fk_retail_prices_price_scopes_types FOREIGN KEY (price_scope_id) REFERENCES mn_price_scopes(id)"
    execute "ALTER TABLE mn_retail_prices ADD CONSTRAINT fk_retail_prices_territories FOREIGN KEY (territory_id) REFERENCES mn_territories(id)"
    execute "ALTER TABLE mn_retail_prices ADD CONSTRAINT fk_retail_prices_currencies FOREIGN KEY (currency_id) REFERENCES mn_currencies(id)"
  end
  def self.down
    #ArtistComponents Foreign Keys
    execute "ALTER TABLE mn_artist_components DROP FOREIGN KEY fk_artist_components_components"
    execute "ALTER TABLE mn_artist_components DROP FOREIGN KEY fk_artist_components_artists"
    execute "ALTER TABLE mn_artist_components DROP FOREIGN KEY fk_artist_components_artist_types"
    #ArtistMetadata Foreign Keys 
    execute "ALTER TABLE mn_artist_metadata DROP FOREIGN KEY fk_artist_metadata_artists"
    execute "ALTER TABLE mn_artist_metadata DROP FOREIGN KEY fk_artist_metadata_metadata_type"
    #ComponentActions Foreign Keys
    execute "ALTER TABLE mn_component_actions DROP FOREIGN KEY fk_component_actions_components"
    #ComponentParent Foreign Keys
    execute "ALTER TABLE mn_component_parents DROP FOREIGN KEY fk_component_parents_components"
    execute "ALTER TABLE mn_component_parents DROP FOREIGN KEY fk_component_children_components"
    #Components Foreign Keys
    execute "ALTER TABLE mn_components DROP FOREIGN KEY fk_component_labels"
    execute "ALTER TABLE mn_components DROP FOREIGN KEY fk_component_component_types"
    #Labels Foreign Keys
    execute "ALTER TABLE mn_labels DROP FOREIGN KEY fk_labels_label_owners"
    #MediaFiles Foreign Keys
    execute "ALTER TABLE mn_media_files DROP FOREIGN KEY fk_media_files_components"
    #execute "ALTER TABLE media_files DROP FOREIGN KEY fk_media_files_asset_types"
    #Metadata Foreign Keys
    execute "ALTER TABLE mn_metadata DROP FOREIGN KEY fk_metadata_components"
    execute "ALTER TABLE mn_metadata DROP FOREIGN KEY fk_metadata_metadata_types"
    #RelatedComponents Foreign Keys
    execute "ALTER TABLE mn_related_components DROP FOREIGN KEY fk_related_components_components"
    #Wholesale Foreign Keys
    execute "ALTER TABLE mn_wholesale_prices DROP FOREIGN KEY fk_wholesale_prices_components"
    execute "ALTER TABLE mn_wholesale_prices DROP FOREIGN KEY fk_wholesale_prices_price_scopes_types"
    execute "ALTER TABLE mn_wholesale_prices DROP FOREIGN KEY fk_wholesale_prices_territories"
    execute "ALTER TABLE mn_wholesale_prices DROP FOREIGN KEY fk_wholesale_prices_currencies"
    #Asset-Type Foreign Keys
    execute "ALTER TABLE mn_asset_types DROP FOREIGN KEY fk_asset_types_price_scopes_types"
    #RetailPrices Foreign Keys
    execute "ALTER TABLE mn_retail_prices DROP FOREIGN KEY fk_retail_prices_components"
    execute "ALTER TABLE mn_retail_prices DROP FOREIGN KEY fk_retail_prices_price_scopes_types"
    execute "ALTER TABLE mn_retail_prices DROP FOREIGN KEY fk_retail_prices_territories"
    execute "ALTER TABLE mn_retail_prices DROP FOREIGN KEY fk_retail_prices_currencies"   
  end
end