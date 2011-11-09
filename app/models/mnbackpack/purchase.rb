class Mnbackpack::Purchase
  def submit (client_ip)
    mn = Mnbackpack::Request.new
    qstr = mn.create({"Method" => "Purchase.UseBalance", "SiteDomain" => "www.award.fm", "UserIP" => "#{client_ip}"}, true)
    request = Typhoeus::Request.post(qstr,
                                    :params => {
                                      "User" => {
                                        "FirstName" => "Trevor",
                                        "LastName" => "Hinesley",
                                        "EmailAddress" => "thinesley@interoconnect.com",
                                        "BillingAddress" => {
                                          "Address1" => "103 Lucy Lane",
                                          "Address2" => "",
                                          "City" => "Dothan",
                                          "State" => "AL",
                                          "PostalCode" => "36303",
                                          "Country" => "US"
                                        }
                                      },
                                      "Items" => [
                                        {"MnetID" => "59614957",
                                        "ItemType" => "Track",
                                        "Format" => "MP3",
                                        "Price" => 0.99,
                                        "Tax" => 0.00}
                                      ],
                                      "TotalCharge" => 0.99
                                    }
                                    # , :disable_ssl_peer_verification => true
                                    )
    # hydra = Typhoeus::Hydra.new
    #     hydra.queue(request)
    #     hydra.run
    #     response = request.response
    #     puts response.code    # http status code
    #     puts response.time    # time in seconds the request took
    #     puts response.headers # the http headers
    #     puts response.headers_hash # http headers put into a hash
    #     puts response.body    # the response body
    #     response
    Rails.logger.info qstr
    request
  end
end