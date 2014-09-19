class HandlePhotoKey
  include Service

  attribute :model, Object
  attribute :photo_key, String
  validates :model, presence: true
  validate :model_photo_uploadable?

  def call
    ActiveRecord::Base.connection.execute("UPDATE #{table_name} SET photo=#{ActiveRecord::Base.sanitize(photo_identifier)} WHERE #{table_name}.id = #{model.id}")
    model.reload

    if model.photo?
      model.photo.recreate_versions!
      model.photo_processing = true
    end

    errors.add :model, model.errors unless model.save

    model
  end

  private

  def model_photo_uploadable?
    errors.add(:model, 'is not photo uploadable') unless model.respond_to? :photo
  end

  def photo_identifier
    # "model-photos/model-id/dbb6a58c-photo.jpg"
    @photo_identifier ||= photo_key.split("#{model.id}/")[1]
  end

  def table_name
    @table_name ||= model.class.table_name
  end
end
