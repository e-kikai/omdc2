class ContactsController < ApplicationController
  require 'resolv'

  layout "application_02"

  def new
    ### 再利用 ###
    attr = if user_signed_in?
      current_user.slice(:company, :name, :tel).merge({mail: current_user[:email]})
    else
      session[:contact_info] || {}
    end

    @contact = Contact.new(attr)
  end

  def create
    @contact = Contact.new(contact_params)

    unless verify_recaptcha
      flash.now[:alert] = "認証に失敗しました"
      render :new and return
    end

    # ログイン済みの場合は、IDも記録
    @contact[:user_id] = current_user.id if user_signed_in?

    # IPなど記録する
    @contact[:ip]   = ip
    @contact[:host] = (Resolv.getname(ip) rescue "")
    @contact[:ua]   = request.user_agent

    if @contact.save
      # 再利用用情報
      session[:contact_info] = @contact.slice(:company, :name, :mail, :tel, :addr_1)

      ContactMailer.contact(@contact).deliver
      ContactMailer.contact_confirm(@contact).deliver

      redirect_to "/contacts/fin", notice: "事務局へ問い合わせを送信しました。"
    else
      render :new
    end
  end

  def fin
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :company, :mail, :tel, :addr_1, :content, :allow_mail)

  end
end
