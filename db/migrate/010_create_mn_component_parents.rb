class CreateMnComponentParents< ActiveRecord::Migration
  def self.up
    create_table :mn_component_parents, {:id => false} do |t|
      t.integer :parent_component_id
      t.integer :child_component_id
      t.timestamps
    end
    execute "ALTER TABLE mn_component_parents ADD PRIMARY KEY (parent_component_id,child_component_id);"
  end
  def self.down
    drop_table :mn_component_parents
  end
end