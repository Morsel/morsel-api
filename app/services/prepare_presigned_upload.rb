class PreparePresignedUpload
  include Service

  attribute :model, Object
  validates :model, presence: true
  validate :model_photo_uploadable?

  def self.store_dir_for_model(model)
    if Rails.env.production? || Rails.env.staging?
      "#{model.class.base_class.to_s.underscore}-photos/#{model.id}"
    elsif Rails.env.development?
      "#{Rails.root}/public/uploads_dev/#{model.class.base_class.to_s.underscore}-photos/#{model.id}"
    else
      "#{Rails.root}/spec/support/uploads/#{model.class.base_class.to_s.underscore}-photos/#{model.id}"
    end
  end

  def self.model_from_key(key)
    # Match w/ the first number since we're always assuming the model is an Item
    matches = key.match(/(\d+)/)
    Item.find matches[0] if matches
  end

  def self.short_secure_token
    SecureRandom.uuid.split('-')[0]
  end

  def self.secure_token_for_model(model)
    var = :"@photo_secure_token"
    model.instance_variable_get(var) || model.instance_variable_set(var, PreparePresignedUpload.short_secure_token)
  end

  def call
    if form
      form.fields.merge('url' => form.url.to_s)
    else
      # TODO: Report error
    end
  end

  private

  def model_photo_uploadable?
    errors.add(:model, 'is not photo uploadable') unless model.respond_to? :photo
  end

  def s3
    @s3 ||= AWS::S3.new Settings.aws.credentials
  end

  def default_bucket
    @default_bucket ||= s3.buckets[Settings.aws.buckets.default]
  end

  def form
    @form ||= default_bucket.presigned_post(
      key: key_name,
      acl: :public_read,
      success_action_status: 201
    )
  end

  def key_name
    @key_name ||= "#{PreparePresignedUpload.store_dir_for_model(model)}/#{PreparePresignedUpload.secure_token_for_model(model)}.jpg"
  end
end
