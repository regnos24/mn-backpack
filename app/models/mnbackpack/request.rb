require 'addressable/uri'
require 'typhoeus'

class Mnbackpack::Request
  attr_accessor :query_filters, :request
  def initialize
    @query_filters = %w(artist Artist genre Genre title Title keyword Keyword rights Rights name Name PageSize pagesize Page page CC cc Addr addr ipString ipstring ISRC isrc AMGID amgid IncludeExplicit include_explicit)
  end
  
  def create(arg_hash, signature=false)
    begin
      (Rails.env == "production") ? mnet = MN_CONFIG["production"] : mnet = MN_CONFIG["development"]
      uri = Addressable::URI.parse(mnet["url"])
      arg_hash[:apikey] = mnet["token"]
      if signature
        uri.query_values = arg_hash
        arg_hash[:signature] = HMAC::MD5.new(uri.query).hexdigest
        uri.query_values = arg_hash
      else
        @request = uri.query_values = arg_hash
      end
      uri.site + "?" + uri.query
    rescue => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
    end
  end
  
  def handle_response(response)
    if response.code == 200
      JSON.parse(response.body)
    elsif response.code == 404
      nil
    else
      raise response.body
    end
  end
  
  def filter(args)
    send_args={}
    args.each do |k, v|
      send_args[k] = v.to_s if (@query_filters.include?(k.to_s))
    end
    send_args
  end
  def single(search_type, args={})
    request = self.create({:method => search_type, :format => "json"}.merge(self.filter(args)))
    Rails.logger.error request
    begin
      response = Typhoeus::Request.get(request)
      self.handle_response(response)
    rescue => e
      Rails.logger.error e
    end
  end
  
  def many(requests)
    if requests[:search].nil?
      raise "Please supply a Hash with a nested :search Array for :Search ex: .find(:all ,{search: [{method: 'artist',keyword: 'Beatles'}})"
    end
    sendback = []
    hydra = Typhoeus::Hydra.new
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
      puts qstr
      request = Typhoeus::Request.new(qstr)
      request.on_complete do |response|
       sendback << self.handle_response(response)
      end
      hydra.queue request
    end
    hydra.run
    sendback
  end
end