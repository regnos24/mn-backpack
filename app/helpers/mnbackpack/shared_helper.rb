module Mnbackpack
  module SharedHelper
    require 'hmac-md5'
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
    
    def generate_widget_secret(order_id)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('md5'),MN_CONFIG[Rails.env]["secret"],"#{order_id}," + MN_CONFIG[Rails.env]["widget"])
    end
  end
end