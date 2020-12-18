CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => Rails.application.secrets.aws_access_key_id,
      :aws_secret_access_key  => Rails.application.secrets.aws_secret_access_key,
      :region                 => 'ap-northeast-1', # Tokyo
      :path_style             => true,
  }

  config.fog_public     = true # public-read
  config.fog_attributes = {'Cache-Control' => 'public, max-age=86400'}

  # case Rails.env
  #   when 'production'
  #     config.fog_directory = 'omdc2'
  #     config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/omdc2'
  #   when 'staging'
  #     # config.fog_directory = 'staging.omdc2'
  #     # config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/staging.omdc2'
  #
  #     config.fog_directory = 'omdc2'
  #     config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/omdc2'
  #
  #   when 'development'
  #     config.fog_directory = 'development.omdc2'
  #     config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/development.omdc2'
  #   when 'test'
  #     config.fog_directory = 'test.omdc2'
  #     config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/test.omdc2'
  # end

  config.fog_directory = Rails.application.secrets.aws_s3_bucket
  config.asset_host    = "https://s3-ap-northeast-1.amazonaws.com/#{Rails.application.secrets.aws_s3_bucket}"

end
