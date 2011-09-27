class CreateMnComponentTypes < ActiveRecord::Migration
  def self.up
    create_table :mn_component_types do |t|
      t.string :type_code, :parent_ind, :genre_category
      t.timestamps
    end
  end
  def self.down
    drop_table :mn_component_types
  end
end