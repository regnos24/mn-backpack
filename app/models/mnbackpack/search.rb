class Mnbackpack::Search
  
  def persisted?
    false
  end
  
  class << self
    def find(*args)
      options = extract_options_from_args!(args)
      case args.first
          when 'track', :track then result = find_one('search.gettracks', options)
          when :tracks, 'tracks' then result = find_many(options)
          when 'album', :album then result = find_one('search.getalbums', options)
          when 'albums', :albums then  result = find_many(options)
          when 'artist', :artist then result = find_one('search.getartists', options)
          when 'artists', :artists then result = find_many(options)
          when 'geo', 'geolocation', :geo then result = find_one('search.getgeolocation', options)
          when 'contents', 'content', :content then result = find_one('search.contentmatch', options)
          when :all, :many, 'all','many'   then result = find_many(options)
          else  raise "#{args.first} Method not allowed"
      end
      result
    #      #       mn = Mnbackpack::Request.new()
    #      #       request = mn.create({:method => type, :format => "json"}.merge(request.filter(args)))
    #      #       response = Typhoeus::Request.get(request)
    end
    
    def find_one(type,options)
      #instaniate_record(record)
      mn = Mnbackpack::Request.new
      mn.single(type, options)
    end
    
    def find_many(options)
      mn = Mnbackpack::Request.new
      mn.many(options)
      #instaniate_record(record)
    end
    
    def extract_options_from_args!(args)
      args.last.is_a?(Hash) ? args.pop : {}
    end
    def instaniate_record(album)
      new(Search,true).tap do |resource|
        resource.raw = album.get()
        unless resource.raw.empty?
          resource.content = JSON.parse(resource.raw)
        end
      end
    end
  end
  
end