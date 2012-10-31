class CreateMnLabels < ActiveRecord::Migration
  def self.up
    create_table :mn_labels do |t|
      t.references :label_owner
      t.string :name, :active
      t.timestamps
    end
  end
  def self.down
    drop_table :mn_labels
  end
end