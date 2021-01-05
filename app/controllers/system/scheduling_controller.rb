class System::SchedulingController < ApplicationController
  protect_from_forgery only: [:index]

  def index
  end

  # 定期実行処理
  def vectors_process
    @open_now.process_and_cache_all

    render plain: 'OK', status: 200
  end
end
