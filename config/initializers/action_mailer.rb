require_relative '../../lib/mail_interceptor'

# if Rails.env.development?
#   ActionMailer::Base.delivery_method = :letter_opener
# else
  ActionMailer::Base.raise_delivery_errors = true
  ActionMailer::Base.default_url_options   = { :host => 'localhost' }
  ActionMailer::Base.delivery_method       = :smtp
  ActionMailer::Base.smtp_settings = {
    address:              Rails.application.secrets.mail_smtp_server,
    port:                 587,
    user_name:            Rails.application.secrets.mail_user_name,
    password:             Rails.application.secrets.mail_passwd,
    authentication:       :plain,
    enable_starttls_auto: true
  }
# end

### 自分宛てに転送 ###
ActionMailer::Base.register_interceptor(MailInterceptor) if Rails.env.staging?
ActionMailer::Base.register_interceptor(MailInterceptor) if Rails.env.development?
