class Mnbackpack::Genre < ActiveRecord::Base
  set_table_name 'mn_genres'
  def to_json
    super(:except => :password)
  end
end