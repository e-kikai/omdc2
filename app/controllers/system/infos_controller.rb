class System::InfosController < System::ApplicationController
  def index
    @infos = Info.order(:id)
  end

  def edit
    @info = Info.find(params[:id])
  end

  def update
    @info = Info.find(params[:id])
    if @info.update(info_params)
      redirect_to "/system/infos/", notice: "#{@info.title}を変更しました"
    else
      render :edit
    end
  end

  private

  def info_params
    params.require(:info).permit(:comment)
  end
end
