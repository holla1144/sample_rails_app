if Rails.env.production?
  CarrierWave.configure do |config|
    config.storage    = :aws
    config.aws_acl    =  'private'
    config.aws_bucket =  ENV['S3_BUCKET']

    config.aws_credentials = {
        # Configuration for Amazon S3
        :access_key_id     => ENV['S3_ACCESS_KEY'],
        :secret_access_key => ENV['S3_SECRET_KEY'],
        :region            => ENV['S3_REGION']
    }
  end
end