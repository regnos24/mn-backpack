class Mnbackpack::Track
  
  def self.get(mnetid)
    mn = Mnbackpack::Request.new
    mn.single('Track.Get', {"MnetId" => "#{mnetid}"})
  end
  def self.find(mnetid)
    self.get(mnetid)
  end
  def self.locations(mnetids)
    mn = Mnbackpack::Request.new
    mn.single('Track.Get', {"MnetIds" => "#{mnetids.join('|')}", signature: true})
  end
  def self.all(options={})
    mn = Mnbackpack::Request.new
    mn.single('search.gettracks', options)
  end
end