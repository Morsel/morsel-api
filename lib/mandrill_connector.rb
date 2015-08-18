require 'mandrill'
class MaindrillConnector

  def initialize name = 'Morsel Subscription', group = 'no group'
    @client = Mandrill::API.new 'Zf69n9NANLl6gxjdjFleYA'        
  end

  def get_client
    @client
  end 
end