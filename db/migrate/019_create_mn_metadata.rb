class CreateMnMetadata < ActiveRecord::Migration
  def self.up
    create_table :mn_metadata do |t|
      t.references :component, :metadata_type
      t.integer :type_id
      t.string :value
      t.timestamps
    end
  end
  def self.down
    drop_table :mn_metadata
  end
end