require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

require "charwidth"
require "charwidth/string"
# require "charwidth/active_record"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Omdc2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # config.active_record.raise_in_transactional_callbacks = true

    config.assets.paths << "#{Rails}/vendor/assets/fonts"

    I18n.available_locales = I18n.available_locales.push(:ja)
    config.i18n.default_locale = :ja

    config.active_record.default_timezone = :local
    config.time_zone = 'Tokyo'

    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: true,
        request_specs: false
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end

    config.mail_logger = Logger.new("log/mail_#{Rails.env}.log")

    config.image_upload_logger = Logger.new("log/image_upload.log")
  end
end
