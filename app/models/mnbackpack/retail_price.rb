class Mnbackpack::RetailPrice < ActiveRecord::Base
  set_table_name 'mn_retail_prices'
  belongs_to :component, :class_name => 'Mnbackpack::Component'
end