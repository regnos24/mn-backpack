require 'addressable/uri'
require 'typhoeus'
require 'hmac-md5'

class Mnbackpack::Request
  attr_accessor :query_filters, :request, :cache
  def initialize
    @query_filters = %w(artist Artist genre Genre title Title keyword Keyword rights Rights name Name PageSize pagesize Page page CC cc Addr addr ipString ipstring ISRC isrc AMGID amgid IncludeExplicit include_explicit MnetId mnetid mainArtistOnly mainartistonly Username username OrderID orderid)
    @cache = 24.hours
   puts ':::::::::::: MNBACKPACK Loaded into ' + Rails.env + ' Mode :::::::::::::'
  end
  
  def create(arg_hash, signature=false)
    begin
      case Rails.env
      when 'production' 
        mnet = MN_CONFIG["production"]
      when 'staging' 
        mnet = MN_CONFIG["staging"]
      else 
        mnet = MN_CONFIG["development"]
      end
      uri = Addressable::URI.parse(mnet["url"])
      arg_hash[:apikey] = mnet["token"]
      if signature
        uri.query_values = arg_hash
        arg_hash[:signature] =  OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('md5'),mnet["secret"],uri.query)
        uri.query_values = arg_hash
      else
        @request = uri.query_values = arg_hash
      end
      puts '<<< Medianet Request ' + uri.site + "?" + uri.query + ' >>>'
      uri.site + "?" + uri.query
    rescue => e
      puts e.message
      puts e.backtrace
    end
  end
  
  def handle_response(response)
    if response.is_a? Hash
      response
    else
      if response.code == 200
        JSON.parse(response.body)
      elsif response.code == 404
        nil
      elsif response.code == 302
        nil
      else
        raise response.inspect
      end
    end
  end
  
  def filter(args)
    send_args={}
    args.each do |k, v|
      send_args[k] = v.to_s if (@query_filters.include?(k.to_s))
    end
    send_args
  end
  
  def single(search_type, args={}, no_cache=false)
    begin
      hydra = Typhoeus::Hydra.new
      hydra.cache_getter do |request|
        if(request.cache_timeout == 0)
          Rails.cache.fetch(request.cache_key, force: true)  rescue nil
        else
          Rails.cache.read(request.cache_key)  rescue nil
        end
      end
      hydra.cache_setter do |request|
         Rails.cache.write(request.cache_key,self.handle_response(request.response),expires_in: request.cache_timeout, race_condition_ttl: 10)
      end
      qstr= self.create({:method => search_type, :format => "json"}.merge(self.filter(args)), args[:signature])
      if(no_cache)
        request = Typhoeus::Request.new(qstr,cache_timeout: 0)
      else
        request = Typhoeus::Request.new(qstr,cache_timeout: @cache)
      end
      request.on_complete do |response|
        self.handle_response(response)
      end
      hydra.queue request
      hydra.run
      request.handled_response
    rescue => e
      puts e.inspect
      puts e.backtrace
    end
  end
  
  def many(requests, hash = false, no_cache=false)
    if requests[:search].nil?
      raise "Please supply a Hash with a nested :search Array for :Search ex: .find(:all ,{search: [{method: 'artist',keyword: 'Beatles'}})"
    end
    (hash) ? sendback = {} : sendback = []
    hydra = Typhoeus::Hydra.new
    hydra.cache_getter do |request|
      if(request.cache_timeout == 0)
        Rails.cache.fetch(request.cache_key, force: true)  rescue nil
      else
        Rails.cache.read(request.cache_key)  rescue nil
      end
    end
    hydra.cache_setter do |request|
       Rails.cache.write(request.cache_key,self.handle_response(request.response),expires_in: request.cache_timeout, race_condition_ttl: 10)
    end
    requests[:search].each do |r|
      unless r.fetch(:method)
        raise "Please supply the criteria you want to search for as the first element ex: {:method => 'tracks', :other => 'yeah'} #{r.first.class}"
      end
      case r[:method]
        when 'tracks', 'track', :track, :tracks then type = "search.gettracks"
        when 'albums', 'album', :albums, :album then type = "search.getalbums"
        when 'artists', 'artist', :artists, :artist then type = "search.getartists"
        when 'geo', 'geolocation', :geo, :geolocation then type = "search.getgeolocation"
        else raise "No Method found, please use [tracks, albums, artists, geo]"
      end
      qstr= self.create({:method => type, :format => "json"}.merge(self.filter(r)))
      if(no_cache)
        request = Typhoeus::Request.new(qstr,cache_timeout: 0)
      else
        request = Typhoeus::Request.new(qstr,cache_timeout: @cache)
      end
      request.on_complete do |response|
        if sendback.is_a? Array
          sendback << self.handle_response(response)
        else
          sendback[r[:method]] = self.handle_response(response)
        end
      end
      hydra.queue request
    end
    hydra.run
    sendback
  end
  
  def all(requests)
    h = {:search => []}
    %w(artists albums tracks).each do |m|
      h[:search] << {method: m}.merge(self.filter(requests))
    end
    results = self.many(h, true)
    results
  end
end