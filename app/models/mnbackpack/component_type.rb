class Mnbackpack::ComponentType < ActiveRecord::Base
  set_table_name 'mn_component_types'
  belongs_to :component
end