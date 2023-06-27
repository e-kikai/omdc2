CSV.generate do |row|
  head = @results.keys
  row << head

  @pivots.each do |pi|
    data = @results.map do |col, vals|
      if col =~ /(価格|金額|デメ半|数|件|率)/
        vals[pi] || 0
      else
        vals[pi]
      end
    end
    row << data
  end
end
