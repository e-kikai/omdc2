CSV.generate do |row|
  head = @results.keys
  row << head

  @pivots.each do |pi|
    data = @results.map { |col, vals| vals[pi] }
    row << data
  end
end
