class Mnbackpack::Search < Mnbackpack::Request
  
  def persisted?
    false
  end
  
  class << self
    def find(*args)
      no_cache = false
      options = extract_options_from_args!(args)
      case args.first
          when 'track', :track then result = find_one('search.gettracks', options, no_cache)
          when :tracks, 'tracks' then result = find_many(options, no_cache)
          when 'album', :album then result = find_one('search.getalbums', options, no_cache)
          when 'albums', :albums then  result = find_many(options, no_cache)
          when 'artist', :artist then result = find_one('search.getartists', options, no_cache)
          when 'artists', :artists then result = find_many(options, no_cache)
          when 'geo', 'geolocation', :geo then result = find_one('search.getgeolocation', options, no_cache)
          when 'contents', 'content', :content then result = find_one('search.contentmatch', options, no_cache)
          when :many, 'many' then result = find_many(options, no_cache)
          when :all, 'all' then result = find_all(options, no_cache)
          else  raise "#{args.first} Method not allowed"
      end
      result
    #      #       mn = Mnbackpack::Request.new()
    #      #       request = mn.create({:method => type, :format => "json"}.merge(request.filter(args)))
    #      #       response = Typhoeus::Request.get(request)
    end
    
    def find_one(type,options,no_cache=false)
      #instaniate_record(record)
      mn = Mnbackpack::Request.new
      mn.single(type, options)
    end
    
    def find_many(options,no_cache=false)
      mn = Mnbackpack::Request.new
      mn.many(options)
      #instaniate_record(record)
    end
    
    def find_all(options,no_cache=false)
      mn = Mnbackpack::Request.new
      mn.all(options)
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