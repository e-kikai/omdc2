require 'digest/md5'

module Devise
  module Encryptable
    module Encryptors
      class BCryptPlusMD5 < Base
        def self.digest(klass, password)
          super(klass, Digest::MD5.hexdigest(password))
        end
        def self.compare(klass, hashed_password, password)
          super(klass, hashed_password, Digest::MD5.hexdigest(password))
        end
      end
    end
  end
end
