shared_examples 'PresignedPhotoUploadable' do
  context '`prepare_presigned_upload`=true' do
    it 'should modify the Model and respond with a `presigned_upload` object' do
      stub_aws_s3_client
      params = presigned_photo_uploadable_object.merge(prepare_presigned_upload: true)

      case endpoint_method
      when :get
        get_endpoint params
      when :post
        post_endpoint params
      when :put
        put_endpoint params
      end

      expect_success

      expect_json_eq(json_data['presigned_upload'], {
        "AWSAccessKeyId"=>"AWS_ACCESS_KEY_ID",
        "key"=> "KEY-${filename}",
        "policy"=> "POLICY",
        "signature"=>"SIGNATURE",
        "acl"=>"ACL"
      })
    end
  end
end
