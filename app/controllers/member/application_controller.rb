class Member::ApplicationController < ApplicationController
  before_action :authenticate_member!
  before_action { @member = current_member }

  # layout 'layouts/application'
end
