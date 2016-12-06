class System::AreasController < ApplicationController
  before_action :get_area, only: [:edit, :update, :destroy]

  def index
    @areas = Area.all.order(:order_no)
  end

  def new
    @area = Area.new
  end

  def create
    @area = Area.new(area_params)
    if @area.save
      redirect_to "/system/areas/", notice: "#{@area.name}を登録しました"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @area.update(area_params)
      redirect_to "/system/areas/", notice: "#{@area.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @area.soft_destroy!
    redirect_to "/system/areas/", notice: "#{@area.name}を削除しました"
  end

  private

  def get_area
    @area = Area.find(params[:id])
  end

  def area_params
    params.require(:area).permit(:name, :image, :order_no, :remove_image)
  end
end
