class Mnbackpack::Partner < Mnbackpack::Request
  def get_balance
    qstr = create({"Method" => "Partner.GetBalance", :format => "json"}, true)
    response = Typhoeus::Request.get(qstr)
  end
  
  def refill(a = '100')
    qstr = create({"Method" => "Partner.RefillBalance", :format => "json", :amount => "#{a}"}, true)
    #https://ie-api.mndigital.com/?method=partner.refillbalance&format=xml&APIKEY=******API%20KEY******&amount=100&signature=95A748BBF0ED8F26E6B9206021D1179A
    if(Rails.env == 'development')
      raw_xml = '<RefillBalance xmlns="http://api.mndigital.com"><Creditcard><FirstName>First</FirstName><LastName>Last</LastName><Number>4111111111111111</Number><CVV>000</CVV><CardType>Visa</CardType><ExpirationMonth>5</ExpirationMonth><ExpirationYear>2012</ExpirationYear><Address><AddressLine1>2401 Elliott Ave.</AddressLine1><AddressLine2>Suite 300</AddressLine2><City>Seattle</City><State>WA</State><PostalCode>98121</PostalCode><Country>US</Country></Address></Creditcard></RefillBalance>'
      request = Typhoeus::Request.new(qstr,
                                          :body          => raw_xml,
                                          :method        => :post,
                                          :headers       => {"Content-Type" => "application/xml"},
                                          :timeout       => 100000, # milliseconds
                                          :cache_timeout => 60, # seconds
                                          )
      hydra = Typhoeus::Hydra.new
      hydra.queue(request)
      hydra.run
      response = request.response
      response  
    end
  end
end