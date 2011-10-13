class Mnbackpack::Track
  
  def self.get(mnetid)
    mn = Mnbackpack::Request.new
    mn.single('Track.Get', {"MnetId" => "#{mnetid}"})
  end
  def self.locations(mnetids)
    mn = Mnbackpack::Request.new
    mn.single('Track.Get', {"MnetIds" => "#{mnetids.join('|'), signature: true}"})
  end
end