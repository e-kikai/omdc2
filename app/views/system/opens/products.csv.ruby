%w|
  id open_id company_id
  list_no app_no name maker model year spec min_price
  comment created_at updated_at soft_destroyed_at
  genre_id accessory pdfs youtube area_id display
  condition hitoyama carryout_at bids_count same_count
  success_bid_id
  genre large_genre_id large_genre
  xl_genre_id xl_genre
  company area areagroup
  image_thumb, top_image
|.to_csv +
@products.sum do |p|
  areagroup = case p.area&.name
  when /^1階/;  '第1展示場1階'
  when /^2階/;  '第1展示場2階'
  when /^第2/;  '第2展示場'
  when /^屋外/; '屋外'
  else;         '店頭出品'
  end

  [
    p.id, p.open_id, p.company_id,
    p.list_no, p.app_no, p.name, p.maker, p.model, p.year, p.spec, p.min_price,
    p.comment, p.created_at, p.updated_at, p.soft_destroyed_at,
    p.genre_id, p.accessory, p.pdfs, p.youtube, p.area_id, p.display,
    p.condition, p.hitoyama, p.carryout_at, p.bids_count, p.same_count,
    p.success_bid_id,
    p.genre&.name, p.genre&.large_genre_id, p.genre&.large_genre&.name,
    p.genre&.large_genre&.xl_genre_id, p.genre&.large_genre&.xl_genre&.name,
    p.company&.name, p.area&.name, areagroup,
    p&.top_image&.image&.thumb&.url, p&.top_image&.image&.view&.url
  ].to_csv
end.to_s
