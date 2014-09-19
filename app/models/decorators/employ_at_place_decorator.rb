class EmployAtPlaceDecorator < SimpleDelegator
  def employ(user, title)
    errors.add(:title, 'is required') if title.blank?
    errors.add(:user, 'already employed at Place') if users.include? user
    if errors.empty?
      employment = Employment.create(place: __getobj__, user: user, title: title)
      errors.add(:employment, 'is invalid') unless employment.valid?
    end

    employment
  end
end
