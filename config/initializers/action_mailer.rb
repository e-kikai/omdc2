require_relative '../../lib/mail_interceptor'

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.default_url_options   = { :host => 'www.大阪機械団地.jp' }
ActionMailer::Base.delivery_method       = :smtp
ActionMailer::Base.smtp_settings = {
  address:              Rails.application.secrets.mail_smtp_server,
  port:                 587,
  user_name:            Rails.application.secrets.mail_user_name,
  password:             Rails.application.secrets.mail_passwd,
  authentication:       :plain,
  enable_starttls_auto: true
}

case Rails.env
when "staging"
  ActionMailer::Base.default_url_options = { host: '52.198.41.71' }
#   ActionMailer::Base.register_interceptor(MailInterceptor) # 自分宛てに転送
when "development"
  ActionMailer::Base.default_url_options = { host: '192.168.33.110', port: 8082 }
  ActionMailer::Base.register_interceptor(MailInterceptor) # 自分宛てに転送

  # ActionMailer::Base.delivery_method = :letter_opener
end
