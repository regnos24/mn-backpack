class CreateMnAssetTypes < ActiveRecord::Migration
  def self.up
    create_table :mn_asset_types, {:id => false} do |t|
      t.references :price_scope
      t.string :asset_code, :asset_code_tag, :description, :description_code, :drm_code, :file_extension
      t.timestamps
    end
    execute "ALTER TABLE mn_asset_types ADD PRIMARY KEY (asset_code);"
  end
  def self.down
    drop_table :mn_asset_types
  end
end