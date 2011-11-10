class Mnbackpack::Purchase
  def submit (user=nil, cart=nil)
    raise 'User does not have a profile.' if user.profile.nil?
    raise 'Cart does not contain any tracks' if cart.nil?
    
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
                            <LineItem>
                                     <MnetId>521335</MnetId>
                                     <ItemType>Track</ItemType>
                                     <Format>MP3</Format>
                                     <Price>0.99</Price>
                                     <Tax>0.00</Tax>
                            </LineItem>
                    </Items>
                    <TotalCharge>0.99</TotalCharge>
            </UseBalance>
EOF
      Rails.logger.info "*"*50
      Rails.logger.error user.inspect
      Rails.logger.error raw_xml
      Rails.logger.info "*"*50
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