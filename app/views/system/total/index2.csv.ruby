CSV.generate do |row|
  head = @results.keys
  row << head

  @pivots.each do |pi|
    data = @results.map do |col, vals|
      vals[pi] || (col =~ /(価格|金額|デメ半|数|件|率)/ ? 0 : "")
    end
    row << data
  end
end
