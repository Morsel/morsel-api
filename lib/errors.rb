module MorselErrors
  class MorselError < StandardError
  end

  class InvalidPaginationParams < MorselError
  end
end
