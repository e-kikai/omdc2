class System::ContactsController < System::ApplicationController
  def index
    @contacts  = Contact.all.order(id: :desc)

    @pcontacts = @contacts.page(params[:page])
  end
end
