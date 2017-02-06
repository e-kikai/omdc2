class System::ApplicationController < ApplicationController
  before_action :authenticate_system!

  # layout 'layouts/application'

  private

  def get_companies_selector
    @companies_selector = Company.order(:no).pluck("no || ' : ' || name", :id)
    session[:system_company_id] = params[:company_id] if params[:company_id].present?

    @company = Company.find_by(id: session[:system_company_id]) if session[:system_company_id].present?
  end
end
