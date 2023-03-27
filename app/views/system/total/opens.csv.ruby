CSV.generate do |row|
  row << 'aaa'
  head = %w|ID 入札会名|
  @results.keys.each { |key| head << key }

  row << head

  @opens.each do |open|
    data = [open[0], open[1]]
    @results.each { |col, vals| data << vals[open[0]] }

    row << data
  end
end
