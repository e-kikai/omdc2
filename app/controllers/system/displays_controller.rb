class System::DisplaysController < ApplicationController
  def index
    @displays = Display.order(:id)
  end

  def edit
    @display = Display.find(params[:id])
  end

  def update
    @display = Display.find(params[:id])
    @display.update(display_params)
  end

  private

  def display_params
    params.require(:display).permit(:display)
  end
end
