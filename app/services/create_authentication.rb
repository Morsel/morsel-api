class CreateAuthentication < BuildAuthentication
  def call
    authentication = super
    authentication.save
    authentication
  end
end
