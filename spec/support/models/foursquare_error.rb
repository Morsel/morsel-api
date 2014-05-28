class FoursquareError
  attr_accessor :code, :errorDetail, :errorType

  def initialize(attributes = {})
    self.code = attributes[:code] || 'code'
    self.errorDetail = attributes[:error_detail] || 'errorDetail'
    self.errorType = attributes[:error_type] || 'errorType'
  end
end
