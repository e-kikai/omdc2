class Bid::ApplicationController < ApplicationController
  before_action :authenticate_company!

  # layout 'layouts/application'
end
