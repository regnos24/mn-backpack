class CreateMnLabelOwners < ActiveRecord::Migration
  def self.up
    create_table :mn_label_owners do |t|
      t.string  :corp_code, :name, :active
      t.timestamps
    end
  end
  def self.down
    drop_table :mn_label_owners
  end
end