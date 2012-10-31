class CreateMnCurrencies < ActiveRecord::Migration
  def self.up
    create_table :mn_currencies do |t|
      t.string :code, :name
      t.timestamps
    end
  end
  def self.down
    drop_table :mn_currencies
  end
end