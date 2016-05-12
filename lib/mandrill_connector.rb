require 'mandrill'
class MaindrillConnector

  def initialize name = 'Morsel Subscription', group = 'no group'
    @client = Mandrill::API.new 'xwUcFmmIxGvJNOd2NelexA'
  end

  def get_client
    @client
  end
end
