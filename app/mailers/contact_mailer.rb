class ContactMailer < ApplicationMailer

  ### 事務局へ通知 ###
  def contact(contact)
    @contact = contact

    mail(
      # to:       "jimukyoku@omdc.or.jp",
      to:       "nyusatsu@omdc.or.jp",
      reply_to: @contact.mail,
      subject:  "機械工具入札会: 問い合わせ通知"
    )
  end

  ### ユーザへ送信確認 ###
  def contact_confirm(contact)
    @contact = contact

    mail(
      to:       @contact.mail,
      # reply_to: "jimukyoku@omdc.or.jp",
      reply_to: "nyusatsu@omdc.or.jp",
      subject:  "機械工具入札会: 問い合わせ送信確認"
    )
  end
end
