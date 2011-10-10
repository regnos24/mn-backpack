class Mnbackpack::ComponentParent < ActiveRecord::Base
  set_table_name 'mn_component_parents'
  belongs_to :component, :class_name => 'Mnbackpack::Component', :foreign_key => 'parent_component_id', :primary_key => "id"
end