class HelpsController < ApplicationController
  def show

    render params[:label]
  end
end
