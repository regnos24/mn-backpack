class Mnbackpack::Purchase
  def submit (user=nil, cart=nil)
    raise 'User does not have a profile.' if user.profile.nil?
    raise 'Cart does not contain any tracks' if cart.nil?
    Rails.logger.info cart.inspect
    mn = Mnbackpack::Request.new
    qstr = mn.create({"Method" => "Purchase.UseBalance", "SiteDomain" => "www.award.fm", "UserIP" => "#{user.current_sign_in_ip}"}, true)
    raw_xml = <<EOF
    <UseBalance xmlns="http://api.mndigital.com">
                <User>
                            <FirstName>#{user.profile.firstname}</FirstName>
                            <LastName>#{user.profile.lastname}</LastName>
                            <EmailAddress>#{user.email}</EmailAddress>
                            <BillingAddress>
                                     <AddressLine1>#{user.profile.address1}</AddressLine1>
                                     <AddressLine2>#{user.profile.address2}</AddressLine2>
                                     <City>#{user.profile.city}</City>
                                     <State>#{user.profile.state}</State>
                                     <PostalCode>#{user.profile.zipcode}</PostalCode>
                                     <Country>#{user.profile.country}</Country>
                            </BillingAddress>
                    </User>
                    <Items>
EOF
        totalprice = 0
        cart.line_items.each do |c|
           raw_xml += "
           <LineItem>
                    <MnetId>#{c.mnetid}</MnetId>
                    <ItemType>Track</ItemType>
                    <Format>MP3</Format>
                    <Price>#{c.price}</Price>
                    <Tax>0.00</Tax>
           </LineItem>"
           totalprice += c.price
        end
        totalprice = sprintf("%.2f", totalprice)
          raw_xml += "               
                    </Items>
                    <TotalCharge>#{totalprice}</TotalCharge>
            </UseBalance>"
    Rails.logger.info "*"*50
    Rails.logger.info raw_xml
        request = Typhoeus::Request.new(qstr,
                                            :body          => raw_xml,
                                            :method        => :post,
                                            :headers       => {"Content-Type" => "application/xml"},
                                            :timeout       => 100000, # milliseconds
                                            :cache_timeout => 60, # seconds
                                            # :params => {:content => "#{xml}"}
                                            )
        hydra = Typhoeus::Hydra.new
        hydra.queue(request)
        hydra.run
        response = request.response
        response
  end
end