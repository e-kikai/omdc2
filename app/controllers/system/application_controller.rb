class System::ApplicationController < ApplicationController
  before_action :authenticate_system!

  # layout 'layouts/application'
end
