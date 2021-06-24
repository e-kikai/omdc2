module LinkSource
  extend ActiveSupport::Concern

  included do
    before_save :check_robot
  end

  ROBOTS = /(goo|google|yahoo|naver|ahrefs|msnbot|bot|crawl|amazonaws|rate-limited-proxy)/i
  KWDS   = {
    "mail" => "メール", "top" => "トップページ", "dtl" => "詳細", "src" => "検索結果", "fav" => "お気に入り",

    "lno" => "No.順リスト", "spc" => "特集",
    "xgn" => "大ジャンル", "lgn" => "中ジャンル", "gnl" => "ジャンル",

    "fav" => "お気に入り",
    "nms" => "画像特徴検索", "nms" => "画像ファイル検索", "nmr" => "似た商品", "sge" => "同ジャンル", "hist" => "閲覧履歴",

    "pnl" => "パネル表示", "lst" => "リスト表示",

    # リロード
    "reload" => "リロード", "back" => "履歴",

    # 紙媒体
    "flyer" => "チラシ", "poster" => "ポスター", "plist" => "紙リスト",
    "qr" => "下げ札",

    # 一括配信メール
    "cmp" => "Mailchimp", "mailchimp" => "Mailchimp",

    # 外部サイト
    "machinelife" => "マシンライフ", "dst" => "デッドストック", "ekikai" => "e-kikai", "mnok" => "ものオク",

    # モバイル
    "pc" => "PC", "mb" => "モバイル",

    # 特集
    "01" => "1万円特集", "02" => "ひとやま特集",
  }

  ### リンク元の生成 ###
  def link_source
    self.class.link_source_base(r, referer)
  end

  module ClassMethods
    def link_source_base(r, referer)
      if r.present?
        r.split("_").map { |kwd| KWDS[kwd] || kwd }.reject(&:blank?).join(" | ")
      else
        case referer

        # 検索・SNS
        when /\/www\.google\.(com|co)\//;      "Google"
        when /\/search\.yahoo\.co\//;          "Yahoo"
        when /bing\.com\//;                    "bing"
        when /baidu\.com\//;                   "百度"

        when /\/t\.co\//;                      "Twitter"
        when /facebook\.com\//;                "FB"
        when /youtube\.com\//;                 "YouTube"
        when /googleads\.g\.doubleclick\.net/; "広告"
        when /tpc\.googlesyndication\.com/;    "広告"
        when /\/www\.googleadservices\.com/;   "広告"
        # e-kikai
        when /\/www\.zenkiren\.net/;           "マシンライフ"
        when /\/www\.zenkiren\.org/;           "全機連"
        when /\/www\.e-kikai\.com/;            "e-kikai"
        # when /\/www\.xn\-\-4bswgw9cs82at4b485i\.jp\//; "電子入札システム"
        # when /\/www\.大阪機械団地\.jp\//;              "電子入札システム"
        when /\/www\.deadstocktool\.com/;      "DST"
        when /\/www\.mnok\.net/;               "ものオク"

        # 電子入札システム内
        when /\/www\.(xn\-\-4bswgw9cs82at4b485i|大阪機械団地)\.jp\/?(.*)$/ then
          case $2
          when /(r=.*)?$/;               "トップページ"
          when /^produts(\?)/;           "検索結果"
          when /^produts\/([0-9]+)/;     "詳細 : #{$1}"
          when /^xl_genre\/([0-9]+)/;    "大ジャンル : #{$1}"
          when /^large_genre\/([0-9]+)/; "中ジャンル : #{$1}"
          when /^genre\/([0-9]+)/;       "ジャンル : #{$1}"
          when /^special\/([0-9]+)/;     "特集 : #{$1}"
          when /^products\/[0-9]+\/image_vector_search\/([0-9]+)/; "画像特徴検索 : #{$1}"
          when /^mypage\/favorites/;     "お気に入り"
          when /^helps/;                 "ヘルプ"

          when /^bids/;   "組合員ページ"
          when /^system/; "管理者ページ"
          else; $2
          end

        when /\/\/(.*?)(\/|$)/; $1
        else;                   "(不明)"
        end
      end
    end
  end

  private

  def check_robot
    host !~ ROBOTS && ip.present?
  end
end