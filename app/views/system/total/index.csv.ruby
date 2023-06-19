CSV.generate do |row|
  row << @result.columns
  @result.rows.each { |r| row << r }
end
