class Open < ApplicationRecord
  soft_deletable
  default_scope { without_soft_destroyed }

  # 現在開催中の入札会を取得
  scope :now, -> {
    where('entry_start_date <= ?', Date.now).where('carry_out_end_date >= ?', Date.now).first
  }

  # 現在の入札会の状態を取得
  def status do
    case Date.now
    when entry_start_date..entry_end_date;         :entry
    when carry_in_start_date..carry_in_end_date;   :carry_in
    when carry_in_end_date..preview_start_date;    :list
    when preview_start_date..preview_end_end;      :preview
    when carry_out_start_date..carry_out_end_date; :carry_out
    else                                           :none
    else
  end

  def bid? do
    Date.now === bid_start_at..bid_end_at ? true : false
  end
  
end
