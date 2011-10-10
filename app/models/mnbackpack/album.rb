class Mnbackpack::Album
  def self.albums(mnetid)
    mn = Mnbackpack::Request.new
    mn.single('Album.GetTracks', {"MnetId" => "#{mnetid}", "IncludeExplicit" => "false", "Pagesize" => "20"})
  end
end