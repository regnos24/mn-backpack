class Mnbackpack::Purchase
  def submit (client_ip)
    mn = Mnbackpack::Request.new
    qstr = mn.create({"Method" => "Purchase.UseBalance", "SiteDomain" => "www.award.fm", "UserIP" => "#{client_ip}"}, true)
    xml = Builder::XmlMarkup.new
    xml.instruct! 
     # :xml, :version => "1.0", :encoding => "UTF-8"
    xml.UseBalance(:xmlns => "http://api.mndigital.com") do
      xml.User do
        xml.FirstName "Trevor"
        xml.LastName "Hinesley"
        xml.EmailAddress "thinesley@interoconnect.com"
        xml.BillingAddress do
          xml.Address1 "103 Lucy Lane"
          xml.Address2 ""
          xml.City "Dothan"
          xml.State "AL"
          xml.PostalCode "36303"
          xml.Country "US"
        end
      end 
      xml.Items do
        xml.LineItem do
          xml.MnetID "59614957"
          xml.ItemType "Track"
          xml.Format "MP3"
          xml.Price 0.99
          xml.Tax 0.00
        end
      end
      xml.TotalCharge 0.99
    end
    raw_xml = '<UseBalance xmlns="http://api.mndigital.com">
            <User>
                    <FirstName>Trevor</FirstName>
                    <LastName>Hinesley</LastName>
                    <EmailAddress>thinesley@interoconnect.com</EmailAddress>
                    <BillingAddress>
                             <AddressLine1></AddressLine1>
                             <AddressLine2>NA</AddressLine2>
                             <City>Seattle</City>
                             <State>WA</State>
                             <PostalCode>98102</PostalCode>
                             <Country>UNITED STATES</Country>
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
    </UseBalance>'
    # request = Typhoeus::Request.post(qstr, :body => xml.to_s)xml.to_s.length
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
    Rails.logger.error request
    response
  end
end