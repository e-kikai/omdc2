module ProductsHelper
  ### お気に入りボタン生成 ###
  def favorite(product, r="")
    if user_signed_in?
      ac, ti = if current_user.favorite?(product.id)
        ["active", "お気に入りから削除"]
      else
        ["", "お気に入りに追加"]
      end

      link_to("/mypage/favorites/toggle?id=#{product.id}&r=#{r}",
        method: :post, remote: true, class: "favorite_star #{ac}",
        data: { pid: product.id, toggle: :tooltip, container: :html, placement: :left, trigger: :hover },
        title: ti) do
        tag.i class: "fas fa-star"
      end

    else
      link_to("/users/login", class: "favorite_star",
        data: { toggle: :tooltip, container: :html, placement: :left, trigger: :hover, html: :true },
        title: "ログインすると<br />お気に入りを利用できます") do
        tag.i class: "fas fa-star"
      end
    end
  end
end
