class Mnbackpack::Album
  
  def self.get(mnetid)
    mn = Mnbackpack::Request.new
    mn.single('Album.GetTracks', {"MnetId" => "#{mnetid}", "IncludeExplicit" => "false", "Pagesize" => "20"})
  end
  
  def self.albums(mnetid)
    mn = Mnbackpack::Request.new
    mn.single('Album.GetTracks', {"MnetId" => "#{mnetid}", "IncludeExplicit" => "false", "Pagesize" => "20"})
  end
  
  def self.all(options={})
    mn = Mnbackpack::Request.new
    mn.single('search.getalbums', options)
  end
  
end