class System::ApplicationController < ApplicationController
  before_action :authenticate_system!
  before_action { @system = current_system }

  # layout 'layouts/application'
end
