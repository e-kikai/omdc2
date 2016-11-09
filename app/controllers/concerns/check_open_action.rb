class CheckOpenAction
  def before(controller)
    redirect_to "/bid/", alert: "現在、開催されている入札会はありません" unless @open_now
  end
end
