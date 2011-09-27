class CreateMnComponents < ActiveRecord::Migration
  def self.up
    create_table :mn_components do |t|
      t.references :label
      t.string :comp_code
      t.references :component_type
      t.string :active_status_code, :title, :sort_title,:subtitle, :duration, :parental_advisory, :upc, :child_items_count
      t.date :release_date
      t.string :cover_art, :single
      t.text :short_description, :description
      t.integer :season
      t.string :isrc #International Standard Recording Code
      t.integer :item_number, :disc_number
      t.string :audio_languages, :subtitle_languages, :amg_id, :muze_id, :exclusive_ind
      t.date :publish_date
      t.string :special_codes
      t.timestamps
    end
  end
  def self.down
    drop_table :mn_components
  end
end