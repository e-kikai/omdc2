class System::DetailLogsController < System::ApplicationController
  include Exports
  include DateSelector

  before_action :date_selector, only: [:index]

  def index
    @detail_logs  = DetailLog.includes(:user, product: [:company, :area, :success_bid, :success_company, :genre,:large_genre, :xl_genre]).where(@where).order(id: :desc)

    @detail_logs  = @detail_logs.where(" detail_logs.host !~* 'google' ")

    @pdetail_logs = @detail_logs.page(params[:page]).per(100)

    respond_to do |format|
      format.html
      format.csv { export_csv "detail_logs.csv" }
    end
  end

  ### ユーザ別ログ出録 ###
  def search
    ### 日付設定 ###
    @date_start = (params[:date_start] || Date.today - 1.week).to_date
    @date_end   = (params[:date_end] || Date.today).to_date
    where   = {created_at: @date_start.beginning_of_day..@date_end.end_of_day}
    reorder = {created_at: :desc}

    ### ユーザ指定 ###
    logs = if params[:user_id].present?
      if params[:user_id].strip =~ /^[0-9]+$/
        ### ユーザID指定 ###
        @user = User.find(params[:user_id])

        user_where = {user_id: params[:user_id]}

        # ログデータ取得・結合
        @datail_logs  = DetailLog.includes(:user, :product).where(where).where(user_where)
        @search_logs  = SearchLog.includes(:user).where(where).where(user_where)
        @toppage_logs = ToppageLog.includes(:user).where(where).where(user_where)

        @favorites    = Favorite.includes(:user, product:[ :category]).where(where).where(user_id:params[:user_id])

        [] + @datail_logs + @search_logs + @toppage_logs + @favorites
      else
        ### IP指定 ###
        where[:ip] = params[:user_id]

        # ログデータ取得・結合
        @datail_logs  = DetailLog.includes(:user, :product).where(where)
        @search_logs  = SearchLog.includes(:user).where(where)
        @toppage_logs = ToppageLog.includes(:user).where(where)

        [] + @datail_logs + @search_logs + @toppage_logs
      end
    else
      ### ユーザ指定なし ###

      # ログデータ取得・結合
      @datail_logs  = DetailLog.includes(:user, :product).where(where)
      @search_logs  = SearchLog.includes(:user).where(where)
      @toppage_logs = ToppageLog.includes(:user).where(where)

      @favorites    = Favorite.includes(:user, product:[ :category]).where(where)

      [] + @datail_logs + @search_logs + @toppage_logs + @favorites
    end

    ### ソート ###
    logs = logs.sort_by { |lo| lo.created_at }.reverse

    ### 事前整形 ###
    @relogs = logs .map do |lo|
      klass = case lo.class.to_s
      when "DetailLog";  ["詳細",           "glyphicon-gift",             "#FF9300"]
      when "SearchLog";  ["検索",           "glyphicon-search",           "#0433FF"]
      when "ToppageLog"; ["トップページ",   "glyphicon-home",             "#AA7942"]
      when "Favorite";   ["お気に入り",     "glyphicon-star",             "#EE0"]
      else;              [lo.class,         "glyphicon-exclamation-sign", "#919191"]
      end

      ### 内容詳細 ###
      con = []
      if lo[:product_id].present? && lo.product
        con << "[#{lo.product.state}]" unless lo.product.state == "中古"

        con << "即売:#{lo.product.prompt_dicision_price}円" if lo.product.prompt_dicision_price

        con << "終了済" if lo.product.dulation_end < lo.created_at
      end

      if lo.class.to_s == "SearchLog"
        if lo[:search_id].present? && lo.search
          con << "特集: #{lo.search.name}"
        else
          con << "キーワード: #{lo.keywords}"                  if lo[:keywords].present?
          con << "カテゴリ: #{lo.category.name}"               if lo[:category_id].present? && lo.category
          con << "出品会社: #{lo.company.company_remove_kabu}" if lo[:company_id].present? && lo.company
          con << "すべてのカテゴリ" if con.blank? && lo[:path].present? && lo[:path] =~ /products($|\?)/
          if lo[:nitamono_product_id].present? && lo.nitamono_product
            con <<  "似たものサーチ: [#{lo.nitamono_product_id}] #{lo.nitamono_product.name}"
          end
          con << "新着: #{$1}"    if lo[:path].present? && lo[:path] =~ /news\/([0-9-]+)/
          con << "出品中を表示"   if lo[:path].present? && lo[:path] =~ /success\=start/
          con << "落札価格を表示" if lo[:path].present? && lo[:path] =~ /success\=success/
        end
      end

      {
        created_at:   lo.created_at,
        klass:        klass,
        ip:           lo[:ip],
        host:         lo[:host],

        user:         user,

        product:      (lo[:product_id].present? && lo.product) ? lo.product : nil,

        page:         lo[:page],
        con:          con,
        referer:      lo[:referer],
        ref:          lo[:referer].present? ? URI.unescape(lo&.link_source.to_s) : "",
        r:            lo[:r],
      }
    end

    respond_to do |format|
      format.html {
        ### ページャ ###
        @prelogs = Kaminari.paginate_array(@relogs, total_count: @relogs.length).page(params[:page]).per(100)
      }
      format.csv {
        export_csv "logs_search_#{params[:user_id]}.csv"
      }
    end

  end
end
