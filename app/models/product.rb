class Product < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  belongs_to :open
  belongs_to :company
  belongs_to :genre
  has_one    :large_genre, through: :genre
  has_one    :xl_genre,    through: :large_genre

  has_many :bids

  enum display: { "一般出品" => 0, "常設コマ" => 10, "単品預り" => 20, "店頭出品" => 30 }

  validate  :check_min_price_to_open
  validates :name,      presence: true
  validates :min_price, presence: true, numericality: { only_integer: true }

  def self.ml_get_genre(product)
    workspaces = "42c03c07608247ef802a8ff6fce5b577"
    services   = "7bde3c5e52ac486e8cd3ea0b8d0f3c4f"
    api_key    = "O4R4QencOUtm3/i/SOseIIHYcmdLVIvIeZYI2JKOinbjEnlmrOXE6JULzHgTBvQlqA0dvh3Wu4+4B3+GMXvKjg=="

    url = "https://ussouthcentral.services.azureml.net/workspaces/#{workspaces}/services/#{services}/score"

    req_params = {
      "Id"       => "score00001",
      "Instance" => {
        "FeatureVector" =>  {
          "list_no" => 1,
          "name"    => product[:name].presence || "((不明))",
          "maker"   => product[:maker].presence || "((不明))",
          "model"   => product[:model].presence || "((不明))",
          "model2"  => product[:model].to_s.gsub(/\s*/, " ").gsub(/\s.*$/, "").upcase.gsub(/[^0-9A-Z]/, "").presence || "((不明))",
          "price"   => product[:min_price].presence || 0,
        },
        "GlobalParameters" => {}
      }
    }

    req_header = {
      "Authorization"  => "Bearer #{api_key}",
      "Content-Type"   => "application/json"
    }

    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host, uri.port.to_s)
    https.use_ssl = true
    # https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP::Post.new(uri.path, req_header)
    req.body = req_params.to_json
    res = https.request(req)

    if res.code == "200"
      res_hash = JSON.parse(res.body)
      res_hash[7].blank? ? res_hash[6].gsub(/\s.*$/, "") : res_hash[7]
    else
      "error : #{res}"
    end
  end

  private

  def check_min_price_to_open
    errors[:min_price] << ("最低入札金額が#{open.rate}円単位ではありません")         if min_price % open.rate > 0
    errors[:min_price] << ("最低入札金額が#{open.lower_price}円未満になっています")  if min_price < open.lower_price
  end

end
