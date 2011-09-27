class CreateMnRelatedComponents < ActiveRecord::Migration
  def self.up
    create_table :mn_related_components, {:id => false} do |t|
      t.references :component
      t.integer :related_comp_id
      t.string :role
      t.timestamps
    end
    execute "ALTER TABLE mn_related_components ADD PRIMARY KEY (component_id,related_comp_id);"
  end
  def self.down
    drop_table :mn_related_components
  end
end