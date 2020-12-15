class ApplicationMailer < ActionMailer::Base
  default from: "機械団地事務局 <nyusatsu@omdc.or.jp>"
  # default from: "admin@e-kikai.com"
  # layout 'mailer'
end

ActionMailer::Base.register_observer(EmailLogObserver.new)
