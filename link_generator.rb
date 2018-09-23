require './config.rb'

row_link = "https://yobit.net/api/3/depth/btc_usd"

Base_arr.each do |a, b|

  row_link += "-#{a}_rur"

  Alt_arr.each do |c|
    
    row_link += "-#{c}_#{a}"
  
  end

end

Alt_arr.each do |c|
  
  row_link += "-#{c}_rur"

end

row_link += "?limit=4"

Link = row_link
