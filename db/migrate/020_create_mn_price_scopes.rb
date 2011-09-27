class CreateMnPriceScopes < ActiveRecord::Migration
  def self.up
    create_table :mn_price_scopes do |t|
      t.string :code
      t.text :description
      t.timestamps
    end
  end
  def self.down
    drop_table :mn_price_scopes
  end
end