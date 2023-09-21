class MailMagazine
  attr_accessor :mailchimp

  def initialize
    @mailchimp = Mailchimp::API.new(Rails.application.secrets.mailchimp_api_key)
    @list_id   = Rails.application.secrets.mailchimp_list_id
  end

  # リストの情報を取得する
  def fetch_mailing_list
    @mailchimp.lists.list
  end

  # リストに対象のメールアドレスがあるか？
  def member?(email)
    result = @mailchimp.lists.member_info(@list_id, [{email: email}])["success_count"]
    result > 0
  end

  # リストに追加
  def add_member(user, email)
    # Rails.logger.debug "########## add_member #{email}"

    ### 応急処置
    @mailchimp.lists.subscribe(
      @list_id, {email: email},
      # {USER_ID: user.id, FNAME: user.name, LNAME: user.company},
      {},
      "html", false)
  end

  # リストから削除
  def remove_member(email)
    # Rails.logger.debug "########## remove_member #{email}"
    @mailchimp.lists.unsubscribe(@list_id, {email: email}, false, false, false)
  end
end
