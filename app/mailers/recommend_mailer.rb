class RecommendMailer < ApplicationMailer
  ### ユーザへ送信確認 ###
  def products(mail, open, genre, products, rtag)
    # @mail     = mail
    @mail     = mail
    @open     = open
    @genre    = genre
    @products = products
    @rtag     = rtag

    mail(
      to:       @mail,
      reply_to: "nyusatsu@omdc.or.jp",
      subject:  "大阪機械卸業団地協同組合 #{@open.name} あなたへのおすすめ出品商品"
    )
  end
end
