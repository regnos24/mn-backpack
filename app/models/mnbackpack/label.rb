class Mnbackpack::Label < ActiveRecord::Base
  set_table_name 'mn_labels'
  belongs_to :component
end