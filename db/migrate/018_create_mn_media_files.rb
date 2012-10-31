class CreateMnMediaFiles < ActiveRecord::Migration
  def self.up
    create_table :mn_media_files do |t|
      t.references :component
      t.string :name, :asset_code
      t.integer :file_size
      t.string :video_size, :bit_rate
      t.timestamps
    end
  end
  def self.down
    drop_table :mn_media_files
  end
end