class System::CompaniesController < ApplicationController
  def index
    @companies = Company.order(:no)
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to "/system/companies/", notice: "#{@company.name}を登録しました"
    else
      render :new
    end
  end

  def edit
    @company = Company.find(params[:id])
  end

  def update
    @company = Company.find(params[:id])
    if @company.update(company_params)
      redirect_to "/system/companies/", notice: "#{@company.name}を変更しました"
    else
      render :edit
    end
  end

  def destroy
    @company = Company.find(params[:id])
    @company.soft_destroy!
    redirect_to "/system/companies/", notice: "#{@company.name}を削除しました"
  end

  private

  def company_params
    params.require(:company).permit(:name, :no, :charge, :representative, :position, :zip, :address, :tel, :fax, :mail, :memo, :entry, :account, :password)
  end
end
