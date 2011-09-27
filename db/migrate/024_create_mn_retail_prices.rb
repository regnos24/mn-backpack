class CreateMnRetailPrices < ActiveRecord::Migration
  def self.up
    create_table :mn_retail_prices do |t|
      t.references :component, :territory, :currency, :price_scope
      t.decimal :price_amount, :precision => 8, :scale => 2
      t.date :effective_from_date, :effective_to_date
      t.timestamps
    end
  end
  def self.down
    drop_table :mn_retail_prices
  end
end