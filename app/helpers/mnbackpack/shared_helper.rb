module Mnbackpack
  module SharedHelper
    def album_pic(id, size=nil)
      path = sprintf('%09d', id).scan(/.../).join('/')
      case size
        when 'large'
          ftype = 'l'
        when 'medium'
          ftype = 'm'
        when 'small'
          ftype = 's'
        else
          ftype = 's'
        end
        image_tag "http://images.mndigital.com/albums/#{path}/#{ftype}.jpeg"
    end
  end
end