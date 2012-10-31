class CreateMnComponentActions < ActiveRecord::Migration
  def self.up
    create_table :mn_component_actions do |t|
      t.references :component
      t.string :set_purchase_from
      t.date :download_from, :sample_dld_from, :stream_from, :transfer2_pd_from, :item_purchase_from, :sample_from, :free_stream_from, :send_to_from, :preorder_from
      t.date :publish_date
      t.timestamps
    end
  end
  def self.down
    drop_table :mn_component_actions
  end
end